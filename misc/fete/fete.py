#!/usr/bin/python
# -*- coding: latin1 -*-

RCS_ID = '$Id: fete.py,v 1.6 2004/10/11 22:35:14 setepo Exp $'

def dolog(*msg):
    import sys
    sys.stderr.write(' '.join(msg) + '\n')

def _safe_unlink(path):
    import os
    try:
        os.unlink(path)
    except OSError, e:
        dolog('No se pudo borrar el fichero temporal %s: %s' % (e.filename, e.strerror))

class NeedUserInput(Exception):
    'Situación que no se puede resolver automáticamente, y está en modo no interactivo'

class Edit:

    def __init__(self, config):
        self.config = config
        self.verbose = config.get('system.verbose')

        # Obtener la lista de comandos a partir de todos los métodos que 
        # comiencen por "action_"
        commands = []
        for at in dir(self):
            if at.startswith('action_'):
                obj = getattr(self, at)
                if callable(obj):
                    commands.append( (at[7:], obj, obj.__doc__) )
        commands.sort()
        self.shell_commands = commands

        # crear el parser de las páginas, el objeto principal para 
        # bajar y subir las páginas del twiki
        import twikiparser
        self.parser = twikiparser.TWiki(config)

    def find(self, text):
        interactive = self.config.get('system.interactivo')
        links = []
        show_head = interactive

        for name, url in self.parser.find(text):
            if show_head:
                print 'Enlaces encontrados'
                show_head = False

            links.append( (name, url) )

            if interactive:
                print '   %3d. %s' % (len(links), name)
            elif len(links) > 1:
                # en modo no-interactivo no se pueden tener más de un enlace
                raise NeedUserInput, 'Se ha encontrado más de un enlace'

        # Comrpobar cuántos enlaces se han encontrado.
        # Si no se ha encontrado ninguno, se sale directamente
        # Si se ha encontrado uno, se devuelve ése
        # Si hay más, se listan y se pregunta cuál se quiere usar.
        if len(links) == 1:
            name, link = links[0]
            if self.verbose:
                dolog('Un enlace encontrado: %s <%s>' % (name, link))
            return name, link
        elif len(links) == 0:
            if not interactive:
                raise NeedUserInput, 'No se ha encontrado ningún enlace'
            dolog('Ningún enlace encontrado')
            return None, None
        else:

            if not interactive:
                raise NeedUserInput, 'Se ha encontrado más de un enlace'

            while True:
                try:
                    i = raw_input('Página a editar (q para salir): ')
                except KeyboardInterrupt:
                    print '^C'
                    return None, None

                if i == 'q':
                    return None, None

                try:
                    opt = int(i)
                except ValueError:
                    continue

                if 0 < opt <= len(links):
                    break

            return links[opt-1]


    def create(self, page):
        self.parser.createpage(page)
        return self.run_shell()

    def edit(self, editlink):
        self.parser.openlink(editlink)
        return self.run_shell()

    def run_shell(self):
        if not self.config.get('system.interactivo'):
            opts = self.config.get('system.cmd_opts')

            import sys
            if opts.script_get:
                sys.stdout.write(self.parser.get_content())
                self.parser.cancel()
            elif opts.script_set:
                self.parser.set_content(sys.stdin.read())
                self.parser.save()
            else:
                return False

            return True


        # Parte "interactiva"... una super shell para decir qué hacer con esto
        self.action_edit()

        while True:
            try:
                opt = raw_input('Orden (help para ayuda): ').strip()
            except EOFError:
                if self.verbose:
                    print 'Cancelando la edición del formulario'
                self.parser.click_on('cancelar')
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
                try:
                    fn = candidates[0][1]
                    res = fn()

                    if res == 'exit':
                        return True
                    elif res == 'continue':
                        pass
                    else:
                        print 'ERROR Interno: Valor desconocido devuelto por la función. Continúa ek programa'

                except KeyboardInterrupt:
                    print '\nAcción cancelada'

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
        fd1, tmp_path1 = tempfile.mkstemp(prefix='fete-diff1')
        fd2, tmp_path2 = tempfile.mkstemp(prefix='fete-diff2')

        p = self.parser
        os.write(fd1, p.get_orig_content())
        os.write(fd2, p.get_content())
        os.close(fd1)
        os.close(fd2)

        pid = os.fork()
        if pid == 0:
            os.execv('/usr/bin/diff', ('diff', '-u', tmp_path1, tmp_path2))
        os.waitpid(pid, 0)

        if self.config.get('system.borrar_temps'):
            os.unlink(tmp_path1)
            os.unlink(tmp_path2)

        return 'continue'

    def action_cancel(self):
        '''Sale sin guardar.'''

        try:
            self.parser.cancel()
        except RuntimeError, e:
            dolog(e)
            dolog('El programa termina igualmente')
        return 'exit'

    action_quit = action_cancel

    def action_save(self):
        '''Sube el contenido de la página y sale'''
        # Como medida "preventiva", comparar si realmente hay 
        # algún cambio que subir. Si no lo hay, no se sube nada
        # y se sigue en el programa.
        if self.parser.get_content() == self.parser.get_orig_content():
            if self.verbose:
                print 'No ha habido cambios aún. No se sube nada'
            return 'continue'

        try:
            self.parser.save()
        except RuntimeError, e:
            print e
            return 'continue'

        return 'exit'

    def action_edit(self):
        '''Abre el editor con el contenido actual'''

        config = self.config

        import tempfile, os
        fd, tmp_path = tempfile.mkstemp(prefix='fete', suffix='.twiki')
        try:

            cf = config.get('system.cabecera_fichero')
            if cf:
                try:
                    s = open(cf).read()
                except IOError, e:
                    print 'ERROR: No se puede abrir %s: %s' % (e.filename, e.strerror)
                else:
                    os.write(fd, s)

            ct = config.get('system.cabecera_texto')
            if ct:
                os.write(fd, ct + '\r\n')

            if self.parser.get_sign() is not None and config.get('editor.poner_firma'):
                os.write(fd, '#### Su firma para la entrada en el diario es\r\n####     ')
                os.write(fd, self.parser.get_sign())
                os.write(fd, '\r\n#### Recuerde que el programa no enviará las líneas que empiecen por ####\r\n####\r\n')

            os.write(fd, self.parser.get_content())
            os.close(fd)

            #if config.use_system
            old_mtime = os.path.getmtime(tmp_path)
            os.system(self.config.get('editor.orden').replace('%P', tmp_path))

            if os.path.getmtime(tmp_path) == old_mtime:
                print 'Sin cambios.'
                return 'continue'

            # nuevo contenido. Filtrar las líneas que empiezan por '####'
            p = open(tmp_path).readlines()
            data = ''.join([x for x in p if not x.startswith('####')])
            self.parser.set_content(data)
            del p

        finally:
            _safe_unlink(tmp_path)

        return 'continue'

    def action_preview(self):
        '''Muesta una vista preliminar de lo que se ha editado hasta ahora'''

        import tempfile, os

        fd, path = tempfile.mkstemp(prefix='fete-preview', suffix = '.html')
        os.write(fd, self.parser.click_on('ver'))
        os.close(fd)

        cmd = self.config.get('editor.ver').replace('%P', path)
        if self.verbose:
            print 'Ejecutando', cmd

        os.system(cmd)

        if self.config.get('system.borrar_temps'):
            _safe_unlink(path)

        return 'continue'

class SystemConfig:

    def __init__(self, cmd_opts):

        import miscfete
        config_file = miscfete.BasicConfig(open(cmd_opts.config_file))

        v = self.__vals = {}

        #
        # system
        #

        v['system.cmd_opts'] = cmd_opts

        # Modo verboso
        verbose = False
        if config_file.system.verbose or cmd_opts.verbose:
            verbose = True
        if cmd_opts.silent:
            verbose = False
        v['system.verbose'] = verbose

        # Modo interactivo
        v['system.interactivo'] = not bool(cmd_opts.script_set or cmd_opts.script_get or cmd_opts.script_run)

        # Contenido a poner al principio
        if cmd_opts.head_file: f = cmd_opts.head_file
        else:                  f = config_file.system.cabecera_fichero
        v['system.cabecera_fichero'] = f

        if cmd_opts.head_str: f = cmd_opts.head_str
        else:                 f= config_file.system.cabecera_texto
        v['system.cabecera_texto'] = f

        v['system.borrar_temps'] = config_file.borrar_temps == 'sí'

        v['system.topic_parent'] = cmd_opts.topicparent

        #
        # usuario
        #

        # Comprobar si se ha escogido algún medio para "disimular" la clave
        # dentro del fichero de configuración
        cod = config_file.usuario.codificada 
        clave = config_file.usuario.clave;
        if len(cod) > 0 and cod not in ('claro', 'base64'):
            dolog('AVISO: El método %s no es válido para guardar la clave. Se mandará tal cual' % cod)
        elif len(clave) > 0:
            if cod == 'base64':
                import base64, binascii
                try:
                    clave = base64.decodestring(clave)
                except binascii.Error:
                    dolog('AVISO: Error al decodificar la clave en base64')
                    clave = None

        v['usuario.nombre'] = config_file.usuario.nombre
        v['usuario.clave'] = clave

        #
        # urls
        #
        v['urls.buscar'] = config_file.urls.buscar
        v['urls.crear'] = config_file.urls.crear
        v['urls.crear_padre'] = config_file.urls.crear_padre

        #
        # editor
        #
        v['editor.orden'] = config_file.editor.orden
        v['editor.poner_firma'] = config_file.editor.poner_firma != 'no'
        v['editor.ver'] = config_file.editor.ver

    def get(self, key):
         return self.__vals[key]

    def __str__(self):
        import pprint
        return pprint.pformat(self.__vals)


def _build_optsparser():
    import optparse
    parser = optparse.OptionParser()
    A = parser.add_option
    A('-c', action='store_true', default=False, dest='create', help='Crea una nueva página')
    A('-v', action='store_true', default=False, dest='verbose', help='Modo verboso')
    A('-q', action='store_true', default=False, dest='silent', help='Modo silencioso')
    A('-f', default='config.ini', dest='config_file', help='Fichero de configuración. default=config.ini')
    A('-p', default='', dest='topicparent', help='Padre de la nueva página a crear')
    A('-a', default='', metavar='TEXTO', dest='head_str', help='Cabecera. Texto a añadir antes de la página')
    A('-A', default='', metavar='FICHERO', dest='head_file', help='Cabecera. Fichero a añadir antes de la página')
    A('-g', action='store_true', default=False, dest='script_get', help='Devuelve por stdout el código fuente de la página y sale')
    A('-s', action='store_true', default=False, dest='script_set', help='Lee de stdin el nuevo código, lo sube, y sale.')
    A('-r', default=None, dest='script_run', help='Programa (filtro) a ejecutar para modificar el fuente')

    return parser

if __name__ == '__main__':

    opts, args = _build_optsparser().parse_args()
    config = SystemConfig(opts)

    cmd = ' '.join(args)
    if not cmd:
        dolog('Debe especificar en la línea de órdenes una cadena a buscar')
    else:
        e = Edit(config)

        try:
            if opts.create:
                e.create(cmd)
            else:
                name, link = e.find(cmd)
                if link is not None:
                    e.edit(link)
        except NeedUserInput, (msg,):
            dolog('ERROR: ' + msg)
            import sys
            sys.exit(1)
