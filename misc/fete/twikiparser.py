# -*- coding: latin1 -*-

RCS_ID = '$Id: twikiparser.py,v 1.1 2004/10/11 22:35:14 setepo Exp $'

import re
RE_editlink = re.compile(r'''<b>(.*?)</b>.*?<a href="javascript:window.open\('(.*?)'\);window.close\(\);">edit</a>''', re.I)
RE_sign = re.compile(r'<strong>(\*\d{8}-\d{1,2}:\d{1,2}-\w+\*)</strong>', re.M)
del re

def dolog(*msg):
    import sys
    sys.stderr.write(' '.join(msg) + '\n')

class TWiki:
    '''TWiki (config)

    Esta clase define todas las operaciones para trabajar directamente con el TWiki.

    find(text)          - Busca la página que cumple con ese patrón de búsqueda
    createpage(page)    - Abre la página indicada 
    openlink(url)       - Carga la página a editar desde la url pasada
    save()              - Pulsa el botón «Guardar» para enviar cambios
    preview()           - Pulsa el botón «Ver» y devuelve el HTML generado
    cancel()            - Pulsa el botón «Cancelar» y devuelve el HTML generado

    get_orig_content()  - Devuelve el contenido original de la página
    get_content()       - Devuelve el contenido actual cambiado
    get_sign()          - Devuelve la firma
    set_content(cont)   - Establece el nuevo contenido
    '''
    

    def __init__(self, config):
        self.config = config
        self.verbose = config.get('system.verbose')

        import miscfete
        self.down = miscfete.Download(config.get('usuario.nombre'), 
                                      config.get('usuario.clave'),
                                      config.get('system.interactivo'))

        # atributos que se establecen cuando se ha cargado una página para editar
        self.original_content = self.cur_content = None
        self.user_sign = ''
        self.form = None

    def find(self, text):
        import urllib, urlparse

        url_base = self.config.get('urls.buscar').replace('%P', urllib.quote_plus(text))

        if self.verbose:
            dolog('Buscando en ' + url_base)

        handle = self.down.open(url_base)
        while True:
            line = handle.readline()
            if not line: break

            m = RE_editlink.search(line)
            if m:
                name, link = m.groups()
                yield name, urlparse.urljoin(url_base, link)

        del handle


    def click_on(self, btn_value):
        # ClientForm no permite hacer búsquedas de controles por su 
        # valor (lo que pone dentro del botón), y ésa es la única forma
        # de diferenciar los botones que aparecen en el formulario del
        # twiki, así que hacemos la búqueda manualmente.
        # Si no se encuentra, salta un RuntimeError

        btn_value = btn_value.lower()
        for ctl in self.form.controls:
            if ctl.value.lower() == btn_value and ctl.type == 'submit':
                if self.verbose:
                    dolog('Pulsando el botón ' + btn_value + '...')

                req = ctl._click(self.form, (1,1), 'request')
                handle = self.down.open(req)
                import miscfete
                return miscfete.read_response(handle.fp)

        raise RuntimeError, 'No se ha encontrado el botón ' + btn_value

    def createpage(self, page):

        tp = self.config.get('system.topicparent')
        if len(tp) > 0:
            url = self.config.get('urls.crear_padre').replace('%U', tp)
        else:
            url = self.config.get('urls.crear')

        web, page = page.split('.', 1)
        url = url.replace('%W', web).replace('%P', page)

        if self.verbose:
            dolog('Abriendo %s/%s desde %s' % (web, page, url))

        return self.openlink(url)

    def openlink(self, editlink):
        down = self.down

        # Abrir la página de edición
        import ClientForm

        class ProxyResp:
            def __init__(self, r):
                self.req = r
                import miscfete
                self.pd = miscfete.ProgressData('Leidos')
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
            dolog('No se ha encontrado formularios en la página para editar')
            return False

        form = None
        for f in forms:
            if f.name == 'main':
                form = f
                break

        if form is None:
            dolog('No se ha encontrado el formuario "main"')
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
        m = RE_sign.search(resp.data)
        if m:
            self.user_sign = m.group(1)
        else:
            self.user_sign = None

        return True

    def save(self):
        # Como medida "preventiva", comparar si realmente hay 
        # algún cambio que subir. Si no lo hay, no se sube nada
        # y se sigue en el programa.
        if self.cur_content == self.original_content:
            if self.verbose:
                dolog('No ha habido cambios aún. No se sube nada')
            return False

        self.click_on('guardar')
        return True

    def cancel(self):
        return self.click_on('cancelar')

    def preview(self):
        return self.click_on('ver')

    def get_orig_content(self):
        return self.original_content

    def get_content(self):
        return self.cur_content

    def set_content(self, data):
        self.cur_content = data
        self.form['text'] = data

    def get_sign(self):
        return self.user_sign

