#!/usr/bin/python
# -*- coding: latin1 -*-

VERBOSE = False
RCS_ID = '$Id: fete.py,v 1.5 2004/10/05 03:18:54 setepo Exp $'

class DownloadError(Exception):
    pass

class ProgressData:

    def __init__(self, prompt, out = None):
        import cStringIO, time

        self.total = 0
        self.last_time = time.time()
        self.last_size = 0
        self.prompt = prompt
        self.data = cStringIO.StringIO()

        if out is None:
            import sys
            self.out = sys.stdout
        else:
            self.out = out

    def add(self, data):
        import time

        self.data.write(data)
        self.total += len(data)

        diff = time.time() - self.last_time

        if diff > 1:
            inc = (self.total - self.last_size) / 1024
            self.out.write('\r%s %d bytes (%.2f K/s)\033[K' % 
                            (self.prompt,
                             self.total, 
                             inc / diff))
            self.out.flush()
            self.last_time = time.time()
            self.last_size = self.total

    def end(self):
        self.out.write('\r\033[K')
        self.out.flush()

    def get(self):
        return self.data.getvalue()

def read_response(fp):

    pd = ProgressData('Leidos')
    while True:
        new = fp.read(2048)
        if not new:
            break

        pd.add(new)

    pd.end()
    return pd.get()

class Download:

    def __init__(self, usuario=None, clave=None, maxintentos = 10):
        self.usuario = usuario
        self.clave = clave
        self.maxintentos = maxintentos

    def open(self, req):
        import urllib2

        #print 'DEBUG: Abriendo', url

        if isinstance(req, str):
            req = urllib2.Request(req)

        intento = 0
        handle = None
        while handle is None:
            intento += 1
            try:
                handle = urllib2.urlopen(req)
            except urllib2.URLError, e:
                if intento > self.maxintentos:
                    raise DownloadError, ('Máximo número de intentos excedido', None)

                if not hasattr(e, 'code'):
                    raise DownloadError, ('No se pudo conectar al servidor', e)

                if e.code == 401:
                    if intento > 1:
                        self.usuario = self.clave = None
                        print ' - Intento #%d' % intento

                    if not self.usuario:
                        self.usuario = raw_input('Usuario: ')
                    if not self.clave:
                        import getpass
                        self.clave = getpass.getpass('Clave para %s: ' % self.usuario)

                    from base64 import encodestring as es
                    req.add_header("Authorization",  "Basic " + es('%s:%s' % (self.usuario, self.clave)).strip())
                else:
                    raise DownloadError, ('No se pudo descargar la url', e)

        return handle


class Edit:

    def __init__(self, config):
        self.config = config

        # comprobar si se ha elegido algún método para guardar la clave
        cod = config.usuario.codificada 
        clave = config.usuario.clave;
        if len(cod) > 0 and cod not in ('claro', 'base64'):
            print 'AVISO: El método %s no es válido para guardar la clave. Se mandará tal cual' % cod
        elif len(clave) > 0:
            if cod == 'base64':
                import base64, binascii
                try:
                    clave = base64.decodestring(clave) + '\n'
                except binascii.Error:
                    print 'AVISO: Error al decodificar la clave en base64'
                    clave = None

        self.down = Download(config.usuario.nombre, clave)

        import re
        self.re_editlink = re.compile(r'''<b>(.*?)</b>.*?<a href="javascript:window.open\('(.*?)'\);window.close\(\);">edit</a>''', re.I)
        self.re_sign = re.compile(r'<strong>(\*\d{8}-\d{1,2}:\d{1,2}-\w+\*)</strong>', re.M)

        # atributos que se establecen cuando se ha cargado una página para editar
        self.original_content = self.cur_content = None
        self.user_sign = ''
        self.form = None

        commands = []
        for at in dir(self):
            if at.startswith('action_'):
                obj = getattr(self, at)
                if callable(obj):
                    commands.append( (at[7:], obj, obj.__doc__) )
        commands.sort()
        self.shell_commands = commands

    def find(self, text):
        import urllib, urlparse

        url_base = self.config.urls.buscar.replace('%P', urllib.quote_plus(text))

        if VERBOSE:
            print 'Buscando en', url_base

        handle = self.down.open(url_base)

        el = self.re_editlink
        links = []

        print 'Enlaces encontrados'

        while True:
            line = handle.readline()
            if not line: break

            m = el.search(line)
            if m:
                name, link = m.groups()
                links.append( (name, urlparse.urljoin(url_base, link)) )

                # mostrar los enlaces a medida que lleguen para 
                # indicar que hay actividad
                print '   %3d. %s' % (len(links), name)

        del handle

        if len(links) == 1:
            name, link = links[0]
            if VERBOSE:
                print 'Un enlace encontrado:', name, link
            return name, link
        elif len(links) == 0:
            print 'Ningún enlace encontrado'
            return None, None
        else:
            while True:
                i = raw_input('Página a editar (q para salir): ')
                if i == 'q':
                    return None, None

                try:
                    opt = int(i)
                except ValueError:
                    continue

                if 0 < opt <= len(links):
                    break

            return links[opt-1]

    def click_on(self, btn_value):
        # ClientForm no permite hacer búsquedas de controles por su 
        # valor (lo que pone dentro del botón), y ésa es la única forma
        # de diferenciar los botones que aparecen en el formulario del
        # twiki, así que hacemos la búqueda manualmente.
        # Si no se encuentra, salta un RuntimeError

        btn_value = btn_value.lower()
        for ctl in self.form.controls:
            if ctl.value.lower() == btn_value and ctl.type == 'submit':
                if VERBOSE:
                    print 'Pulsando el botón', btn_value, '...'

                req = ctl._click(self.form, (1,1), 'request')
                handle = self.down.open(req)
                return read_response(handle.fp)

        raise RuntimeError, 'No se ha encontrado el botón ' + btn_value

    def create(self, page):

        tp = self.config.command_options.topicparent
        if len(tp) > 0:
            url = self.config.urls.crear_padre.replace('%U', tp)
        else:
            url = self.config.urls.crear

        web, page = page.split('.', 1)
        url = url.replace('%W', web).replace('%P', page)

        if VERBOSE:
            print 'Abriendo %s/%s desde %s' % (web, page, url)

        return self.edit(url)

    def edit(self, editlink):
        down = self.down

        # Abrir la página de edición
        import ClientForm

        class ProxyResp:
            def __init__(self, r):
                self.req = r
                self.pd = ProgressData('Leidos')
            def read(self, *a):
                d = self.req.read(*a)
                self.pd.add(d)
                return d
            def __getattr__(self, at):
                return getattr(self.req, at)

        resp = ProxyResp(down.open(editlink))
        forms = ClientForm.ParseResponse(resp)

        resp.pd.end()
        resp.data = resp.pd.get()

        if len(forms) == 0:
            print 'No se ha encontrado formularios en la página para editar'
            return False

        form = None
        for f in forms:
            if f.name == 'main':
                form = f
                break

        if form is None:
            print 'No se ha encontrado el formuario "main"'
            return False

        self.form = form 
        content = 'Textarea no encontrado =('
        for control in form.controls:
            if control.type == 'textarea':
                content = control.value

        self.original_content = content
        self.cur_content = content

        # buscar la "firma" dentro del HTML generado, 
        # para insertarla en el texto
        m = self.re_sign.search(resp.data)
        if m:
            self.user_sign = m.group(1)
        else:
            self.user_sign = None

        self.action_edit()

        # Parte "interactiva"... una super shell para decir qué hacer con esto
        while True:
            try:
                opt = raw_input('Orden (help para ayuda): ').strip()
            except EOFError:
                if VERBOSE:
                    print 'Cancelando la edición del formulario'
                self.click_on('cancelar')
                return
            except KeyboardInterrupt:
                print 
                continue

            if not opt:
                continue

            candidates = []
            for name, fn, desc in self.shell_commands:
                if name.startswith(opt):
                    candidates.append( (name, fn, desc) )

            if len(candidates) == 0:
                print 'No se encuentra ninguna orden coincidente con «%s»' % opt
            elif len(candidates) > 1:
                print 'Ambigüedad.'
                self.action_help(candidates)
            else:
                # un único candidato
                fn = candidates[0][1]
                res = fn()

                if res == 'exit':
                    return True
                elif res == 'continue':
                    pass
                else:
                    print 'ERROR Interno: Valor desconocido devuelto por la función. Continúa ek programa'

        return True

    def action_help(self, cmd = None):
        '''Muestra ayuda de comandos'''

        if cmd is None:
            cmd = self.shell_commands

        width = max([len(item[0]) for item in cmd])
        for item in cmd:
            print '    %s - %s' % (item[0].rjust(width), item[2])

        return 'continue'

    def action_diff(self):
        '''Muestra un diff entre el contenido original y el actual'''
        import tempfile, os
        fd1, tmp_path1 = tempfile.mkstemp()
        fd2, tmp_path2 = tempfile.mkstemp()

        os.write(fd1, self.original_content)
        os.write(fd2, self.cur_content)
        os.close(fd1)
        os.close(fd2)

        pid = os.fork()
        if pid == 0:
            os.execv('/usr/bin/diff', ('diff', '-u', tmp_path1, tmp_path2))
        os.waitpid(pid, 0)

        if self.config.system.borrar_temps != 'no':
            os.unlink(tmp_path1)
            os.unlink(tmp_path2)

        return 'continue'

    def action_cancel(self):
        '''Sale sin guardar.'''

        try:
            self.click_on('cancelar')
        except RuntimeError, e:
            print e
            print 'El programa termina igualmente'
        return 'exit'

    action_quit = action_cancel

    def action_save(self):
        '''Sube el contenido de la página y sale'''
        # Como medida "preventiva", comparar si realmente hay 
        # algún cambio que subir. Si no lo hay, no se sube nada
        # y se sigue en el programa.
        if self.cur_content == self.original_content:
            if VERBOSE:
                print 'No ha habido cambios aún. No se sube nada'
            return 'continue'

        try:
            self.click_on('guardar')
        except RuntimeError, e:
            print e
            return 'continue'

        return 'exit'

    def action_edit(self):
        '''Abre el editor con el contenido actual'''

        config = self.config

        import tempfile, os
        fd, tmp_path = tempfile.mkstemp(suffix='.twiki')
        try:

            if config.system.cabecera_fichero:
                try:
                    s = open(config.system.cabecera_fichero).read()
                except IOError, e:
                    print 'ERROR: No se puede abrir %s: %s' % (e.filename, e.strerror)
                else:
                    os.write(fd, s)

            if config.system.cabecera_texto:
                os.write(fd, config.system.cabecera_texto + '\r\n')

            if self.user_sign is not None and config.editor.poner_firma != 'no':
                os.write(fd, '#### Su firma para la entrada en el diario es\r\n####     ')
                os.write(fd, self.user_sign)
                os.write(fd, '\r\n#### Recuerde que el programa no enviará las líneas que empiecen por ####\r\n####\r\n')

            os.write(fd, self.cur_content)
            os.close(fd)

            #if config.use_system
            old_mtime = os.path.getmtime(tmp_path)
            os.system(self.config.editor.orden.replace('%P', tmp_path))

            if os.path.getmtime(tmp_path) == old_mtime:
                print 'Sin cambios.'
                return 'continue'

            # nuevo contenido. Filtrar las líneas que empiezan por '####'
            p = open(tmp_path).readlines()
            self.cur_content = ''.join([x for x in p if not x.startswith('####')])
            self.form['text'] = self.cur_content
            del p

        finally:
            if self.config.system.borrar_temps != 'no':
                try:
                    os.unlink(tmp_path)
                except OSError, e:
                    print 'No se pudo borrar el fichero temporal %s: %s' % (e.filename, e.strerror)

        return 'continue'

    def action_preview(self):
        '''Muesta una vista preliminar de lo que se ha editado hasta ahora'''

        import tempfile, os

        fd, path = tempfile.mkstemp(suffix = '.html')
        os.write(fd, self.click_on('ver'))
        os.close(fd)

        cmd = self.config.editor.ver.replace('%P', path)
        if VERBOSE:
            print 'Ejecutando', cmd

        os.system(cmd)

        if self.config.system.borrar_temps != 'no':
            os.unlink(path)

        return 'continue'

class ConfigError(Exception):
    pass

class BasicConfig(object):
    # Prescindimos del módulo ConfigParser por ahora, ya que éste 
    # trabaja sólo con diccionaciorios

    def __init__(self, fileobj = None):

        self._values = {}

        if fileobj is None:
            return

        import re
        syntax = [
             (re.compile(r'\s*[;#].*'), lambda: None),
             (re.compile(r'\s*'), lambda: None),
             (re.compile(r'\s*\[\s*(\w+)\s*\]\s*'), self._add_section),
             (re.compile(r'\s*(\w+)\s*=\s*(.*)\s*'), self._add_value)
        ]

        self._numline = 0
        self._cursect = None

        for line in fileobj.xreadlines():
            self._numline += 1
            line = line.strip()
            valid = False

            for regex, fn in syntax:
                m = regex.match(line)
                if m:
                    fn(*m.groups())
                    valid = True

            if not valid:
                raise ConfigError, ('Línea no reconocida', self._numline)

        del self._numline
        del self._cursect

    def _add_section(self, section):
        self._cursect = BasicConfig()
        self._values[section] = self._cursect
        return self._cursect

    def _add_value(self, key, value):
        if self._cursect is None:
            raise ConfigError, ('No se puede establecer un valor antes de abrir una sección', self._numline)

        self._cursect._values[key] = value

    def __getattr__(self, key):
        return self._values.get(key, '')

if __name__ == '__main__':

    import optparse
    parser = optparse.OptionParser()
    A = parser.add_option
    A('-c', action='store_true', default=False, dest='create', help='Crea una nueva página')
    A('-v', action='store_true', default=False, dest='verbose', help='Modo verboso')
    A('-f', default='config.ini', dest='config_file', help='Fichero de configuración. default=config.ini')
    A('-p', default='', dest='topicparent', help='Padre de la nueva página a crear')
    A('-a', default='', metavar='TEXTO', dest='head_str', help='Cabecera. Texto a añadir antes de la página')
    A('-A', default='', metavar='FICHERO', dest='head_file', help='Cabecera. Fichero a añadir antes de la página')

    opts, args = parser.parse_args()

    config = BasicConfig(open(opts.config_file))
    if config.system.verbose or opts.verbose:
        VERBOSE = True

    if opts.head_file:
        config.system.cabecera_fichero = opts.head_file
    if opts.head_str:
        config.system.cabecera_texto = opts.head_str

    config.command_options = opts

    cmd = ' '.join(args)
    if not cmd:
        print 'Debe especificar en la línea de órdenes una cadena a buscar'
    else:
        e = Edit(config)

        if opts.create:
            e.create(cmd)
        else:
            name, link = e.find(cmd)
            if link is not None:
                e.edit(link)

