#!/usr/bin/env python3

"""
 =========================================================================== 

                            PUBLIC DOMAIN NOTICE 
                       Agricultural Research Service 
                  United States Department of Agriculture 

   This software/database is a "United States Government Work" under the 
   terms of the United States Copyright Act.  It was written as part of 
   the author's official duties as a United States Government employee 
   and thus cannot be copyrighted.  This software/database is freely 
   available to the public for use. The Department of Agriculture (USDA) 
   and the U.S. Government have not placed any restriction on its use or 
   reproduction. 

   Although all reasonable efforts have been taken to ensure the accuracy 
   and reliability of the software and data, the USDA and the U.S. 
   Government do not and cannot warrant the performance or results that 
   may be obtained by using this software or data. The USDA and the U.S. 
   Government disclaim all warranties, express or implied, including 
   warranties of performance, merchantability or fitness for any 
   particular purpose. 

   Please cite the author in any work or product based on this material. 

   =========================================================================== 

written by:
    Dave Schneider
    R.W. Holley Center, USDA Agricultural Research Service
    538 Tower Road, Ithaca NY 14853

email: Dave.Schneider@ars.usda.gov
"""

__all__ = ['DynamicRootsLexer']

import sys as sys
import ply.lex as _lex
import logging

from DynamicRootsUtil import RootType

class DynamicRootsLexer(object):

    tokens = ('BRANCH_ID',
              'CLASS',
              'CLASS_ID',
              'FORK_G_DEPTH',
              'H_ORDER',
              'VOLUME',
              'LENGTH',
              'GEOD_DEPTH',
              'VERT_DEPTH',
              'TIP_XYZ',
              'CURVEDNESS',
              'AV_RADIUS',
              'PCA_VERT_ANGLE',
              'N_CHILDREN',
              'IS_LONGER_THAN',
              'PCA_PARENT_CHILD_ANGLE',
              'NUMBER')

    literals = '(,)'

    def __init__(self, debug=False):
        self.lexer = _lex.lex(module=self, debug=debug, optimize=False)

    def t_BRANCH_ID(self, t):
        r'(Branch\ id:)'
        return t

    def t_CLASS(self, t):
        r'(Class:)'
        return t

    def t_CLASS_ID(self, t):
        r'(Primary|Crown|Seminal|Lateral|Unknown)'
        if t.value == 'Primary':
            t.value = RootType.primary
        elif t.value == 'Crown':
            t.value = RootType.crown
        elif t.value == 'Seminal':
            t.value = RootType.seminal
        elif t.value == 'Lateral':
            t.value = RootType.lateral
        elif t.value == 'Unknown':
            t.value = RootType.unknown
        else:
            logging.error('Encountered illegal root type: {0}'.format(t.value))
        return t

    def t_FORK_G_DEPTH(self, t):
        r'(Fork_g_depth:)'
        return t

    def t_H_ORDER(self, t):
        r'(H\ order:)'
        return t

    def t_VOLUME(self, t):
        r'(Volume\ at\ [0-9]+\ time:)'
        return t

    def t_LENGTH(self, t):
        r'(Length\ at\ [0-9]+\ time:)'
        return t

    def t_GEOD_DEPTH(self, t):
        r'(Tip_geod_depth\ at\ [0-9]+\ time:)'
        return t

    def t_VERT_DEPTH(self, t):
        r'(Tip_vert_depth\ at\ [0-9]+\ time:)'
        return t

    def t_TIP_XYZ(self, t):
        r'(Tip\ \(X,Y,Z\)\ at\ [0-9]+\ time:)'
        return t

    def t_CURVEDNESS(self, t):
        r'(Curvedness\ [0-9]+\ time:)'
        return t

    def t_AV_RADIUS(self, t):
        r'(Av_radius\ [0-9]+\ time:)'
        return t

    def t_PCA_VERT_ANGLE(self, t):
        r'(PCA_vert_angle\ [0-9]+\ time:)'
        return t

    def t_N_CHILDREN(self, t):
        r'(N_children\ at\ [0-9]+\ time:)'
        return t

    def t_IS_LONGER_THAN(self, t):
        r'(is_longer_than_parent\ [0-9]+\ time:)'
        return t

    def t_PCA_PARENT_CHILD_ANGLE(self, t):
        r'(PCA_parent_child_angle\ [0-9]+\ time:)'
        return t

    def t_NUMBER(self, t):
        r'(1\.\#J|(\+|\-)?(\d+\.\d+|\d+|\d+\.|\.\d+))'
        try:
            t.value = float(t.value)
        except ValueError:
            logging.error('Cannot convert string \'{0}\' to float'.format(t.value))
            t = None
        return t

    def t_newline(self, t):
        r'(\r\n|\n\r|\n)'
        t.lexer.lineno += 1

    t_ignore = '\t '

    def t_error(self, t):
        logging.error('Lexical error: encountered illegal character \'{0}\' on line {1}'.format(t.value[0], t.lexer.lineno))
        t.lexer.skip(1)

    def build(self, **kwargs):
        self.lexer = _lex.lex(module=self, **kwargs)

