#!/usr/bin/python
# -*- coding: latin1 -*-


VERBOSE = False


class DownloadError(Exception):
    pass

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
                    raise DownloadError, ('M�ximo n�mero de intentos excedido', None)

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
        self.down = Download(config.usuario.nombre, config.usuario.clave)

        import re
        self.re_editlink = re.compile(r'''<b>(.*?)</b>.*?<a href="javascript:window.open\('(.*?)'\);window.close\(\);">edit</a>''', re.I)
        self.re_sign = re.compile(r'<strong>(\*\d{8}-\d{1,2}:\d{1,2}-\w+\*)</strong>', re.M)

        # atributos que se establecen cuando se ha cargado una p�gina para editar
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

        url_base = self.config.urls.buscar.replace('%P', urllib.quote(text))

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
            print 'Ning�n enlace encontrado'
            return None, None
        else:
            while True:
                i = raw_input('P�gina a editar: ')
                try:
                    opt = int(i)
                except ValueError:
                    continue

                if 0 < opt <= len(links):
                    break

            return links[opt-1]

    def click_on(self, btn_value):
        # ClientForm no permite hacer b�squedas de controles por su 
        # valor (lo que pone dentro del bot�n), y �sa es la �nica forma
        # de diferenciar los botones que aparecen en el formulario del
        # twiki, as� que hacemos la b�queda manualmente.
        # Si no se encuentra, salta un RuntimeError

        btn_value = btn_value.lower()
        for ctl in self.form.controls:
            if ctl.value.lower() == btn_value and ctl.type == 'submit':
                if VERBOSE:
                    print 'Pulsando el bot�n', btn_value, '...'

                req = ctl._click(self.form, (1,1), 'request')
                handle = self.down.open(req)
                return handle.read()

        raise RuntimeError, 'No se ha encontrado el bot�n ' + btn_value

    def create(self, page):
        web, page = page.split('.', 1)
        url = self.config.urls.crear.replace('%W', web).replace('%P', page)
        if VERBOSE:
            print 'Creando %s/%s desde %s' % (web, page, url)

        return self.edit(url)

    def edit(self, editlink):
        down = self.down

        # Abrir la p�gina de edici�n
        import ClientForm

        class ProxyResp:
            def __init__(self, r):
                self.req = r
                self.data = ''
            def read(self, *a):
                d = self.req.read(*a)
                self.data += d
                return d
            def __getattr__(self, at):
                return getattr(self.req, at)

        resp = ProxyResp(down.open(editlink))
        forms = ClientForm.ParseResponse(resp)

        if len(forms) == 0:
            print 'No se han encontrado formularios en p�gina para editar'
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

        # Parte "interactiva"... una super shell para decir qu� hacer con esto
        while True:
            try:
                opt = raw_input('Orden (help para ayuda): ').strip()
            except EOFError:
                if VERBOSE:
                    print 'Cancelando la edici�n del formulario'
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
                print 'No se encuentra ninguna orden coincidente con �%s�' % opt
            elif len(candidates) > 1:
                print 'Ambig�edad.'
                self.action_help(candidates)
            else:
                # un �nico candidato
                fn = candidates[0][1]
                res = fn()

                if res == 'exit':
                    return True
                elif res == 'continue':
                    pass
                else:
                    print 'ERROR Interno: Valor desconocido devuelto por la funci�n. Contin�a ek programa'

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

    def action_save(self):
        '''Sube el contenido de la p�gina y sale'''
        # Como medida "preventiva", comparar si realmente hay 
        # alg�n cambio que subir. Si no lo hay, no se sube nada
        # y se sigue en el programa.
        if self.cur_content == self.original_content:
            if VERBOSE:
                print 'No ha habido cambios a�n. No se sube nada'
            return 'continue'

        try:
            self.click_on('guardar')
        except RuntimeError, e:
            print e
            return 'continue'

        return 'exit'

    def action_edit(self):
        '''Abre el editor con el contenido actual'''

        import tempfile, os
        fd, tmp_path = tempfile.mkstemp(suffix='.twiki')
        try:
            if self.user_sign is not None and self.config.editor.poner_firma != 'no':
                os.write(fd, '#### Su firma para la entrada en el diario es\r\n####     ')
                os.write(fd, self.user_sign)
                os.write(fd, '\r\n#### Recuerde que el programa no enviar� las l�neas que empiecen por ####\r\n')

            os.write(fd, self.cur_content)
            os.close(fd)

            #if config.use_system
            old_mtime = os.path.getmtime(tmp_path)
            os.system(self.config.editor.orden.replace('%P', tmp_path))

            if os.path.getmtime(tmp_path) == old_mtime:
                print 'Sin cambios.'
                return 'continue'

            # nuevo contenido. Filtrar las l�neas que empiezan por '####'
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
        '''Muesta una vista prelimiar de lo que se ha editado hasta ahora'''

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
    # Prescindimos del m�dulo ConfigParser por ahora, ya que �ste 
    # trabaja s�lo con diccionaciorios

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
                raise ConfigError, ('L�nea no reconocida', self._numline)

        del self._numline
        del self._cursect

    def _add_section(self, section):
        self._cursect = BasicConfig()
        self._values[section] = self._cursect
        return self._cursect

    def _add_value(self, key, value):
        if self._cursect is None:
            raise ConfigError, ('No se puede establecer un valor antes de abrir una secci�n', self._numline)

        self._cursect._values[key] = value

    def __getattr__(self, key):
        return self._values.get(key, '')

if __name__ == '__main__':

    import optparse
    parser = optparse.OptionParser()
    A = parser.add_option
    A('-c', action='store_true', default=False, dest='create', help='Crea una nueva p�gina')
    A('-v', action='store_true', default=False, dest='verbose', help='Modo verboso')
    A('-f', default='config.ini', dest='config_file', help='Fichero de configuraci�n. default=config.ini')

    opts, args = parser.parse_args()

    config = BasicConfig(open(opts.config_file))
    if config.system.verbose or opts.verbose:
        VERBOSE = True

    cmd = ' '.join(args)
    if not cmd:
        print 'Debe especificar en la l�nea de �rdenes una cadena a buscar'
    else:
        e = Edit(config)

        if opts.create:
            e.create(cmd)
        else:
            name, link = e.find(cmd)
            if link is not None:
                e.edit(link)
