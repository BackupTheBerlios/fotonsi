# -*- coding: latin1 -*-
"""
Devuelve usuario:contraseña del fichero de configuración del fete.
Si se le pasa una url con el parámetro -u devuelve la misma con usuario:contraseña delante del host separado con @
    - el primer modo sirve para el parámetro -auth del lynx, mientras el segundo es genérico para otros navegadores.
    - P.ej. para llamar al elinks se pondría 'elinks `python url_auth.py -c ~/.fete/config.ini -u https://laser.foton.es/twiki/bin/view/TWiki/WebChanges`)
"""
#!/usr/bin/python

import miscfete
import sys

class UrlAuth:
    def __init__(self, opts):
        config_file = miscfete.BasicConfig(open(opts.config_file))
        v = self.__vals = {}

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

        auth = v['usuario.nombre']+':'+v['usuario.clave']

        if opts.auth_url:
            import re
            reg = re.compile(r'(https?://)(.*)', re.IGNORECASE)
            if reg.match(opts.auth_url):
                url = reg.sub(r'\1'+auth+r'@\2', opts.auth_url)
            else:
                url = auth+'@'+opts.auth_url
            print(url)
        else:
            print(auth)

def _build_optsparser():
    import optparse
    parser = optparse.OptionParser()
    A = parser.add_option
    A('-f', default='config.ini', dest='config_file', help='Fichero de configuración. default=config.ini')
    A('-u', default='', dest='auth_url', help='Url para incluir autenticación')

    return parser

if __name__ == "__main__":
    opts, args = _build_optsparser().parse_args()
    cfg = UrlAuth(opts)
