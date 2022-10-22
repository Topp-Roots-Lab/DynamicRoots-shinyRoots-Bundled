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

import logging

import ply.yacc as yacc

from DynamicRootsLexer import *
from DynamicRootsUtil import *

class DynamicRootsParser(object):

    def __init__(self):
        self.lexer = DynamicRootsLexer()
        self.tokens = self.lexer.tokens
        self.parser = yacc.yacc(module=self, debug=False, optimize=False)

    def parse(self, data):
        return self.parser.parse(data, lexer=self.lexer.lexer)
        
    def p_file_expr(self, p):
        'file : data'
        p[0] = p[1]
        
    def p_data_expr(self, p):
        '''data : data line
            | line'''
        if p[1] is None:
            p[1] = [p[2]]
        elif isinstance(p[1], Record):
            p[1] = [p[1]]
        else:
            p[1].append(p[2])

        p[0] = p[1]

    def p_line_expr(self, p):
        'line : branch class fork_depth h_order timesteps'
        p[0] = Record(p[1], p[2], p[3], p[4], p[5])

    def p_branch_id_expr(self, p):
        'branch : BRANCH_ID NUMBER'
        p[0] = int(p[2])

    def p_class_expr(self, p):
        'class : CLASS CLASS_ID'
        p[0] = p[2]

    def p_fork_depth_expr(self, p):
        'fork_depth : FORK_G_DEPTH NUMBER'
        p[0] = float(p[2])

    def p_h_order_expr(self, p):
        'h_order : H_ORDER NUMBER'
        p[0] = int(p[2])

    def p_timesteps_expr(self, p) :
        '''timesteps : timesteps timestep
                 | timestep'''

        if p[1] is None:
            p[1] = [p[2]]
        elif isinstance(p[1], Timestep):
            p[1] = [p[1]]
        else:
            p[1].append(p[2])

        p[0] = p[1]

    def p_timestep_expr(self, p):
        'timestep : volume length geod_depth vert_depth tip_xyz curvedness av_radius pca_vert_angle n_children is_longer_than pca_parent_child_angle'
        p[0] = Timestep(p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11]) 

    def p_volume_expr(self, p):
        '''volume : VOLUME NUMBER
              | VOLUME'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_length_expr(self, p):
        '''length : LENGTH NUMBER
              | LENGTH'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_geod_depth_expr(self, p):
        '''geod_depth : GEOD_DEPTH NUMBER
                  | GEOD_DEPTH'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_vert_depth_expr(self, p):
        '''vert_depth : VERT_DEPTH NUMBER
                  | VERT_DEPTH'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None


    def p_tip_xyz_expr(self, p):
        '''tip_xyz : TIP_XYZ '(' NUMBER ',' NUMBER ',' NUMBER ')' 
               | TIP_XYZ'''
        try:
            if p[3] is None and p[5] is None and p[7] is None:
                p[0] = None
            else:
                p[0] = Point3D(float(p[3]), float(p[5]), float(p[7]))
        except:
            p[0] = None

    def p_curvedness_expr(self, p):
        '''curvedness : CURVEDNESS NUMBER
                  | CURVEDNESS'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_av_radius_expr(self, p):
        '''av_radius : AV_RADIUS NUMBER
                 | AV_RADIUS'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_pca_vert_angle_expr(self, p):
        '''pca_vert_angle : PCA_VERT_ANGLE NUMBER
                     | PCA_VERT_ANGLE'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None

    def p_n_children_expr(self, p):
        '''n_children : N_CHILDREN NUMBER
                  | N_CHILDREN'''
        try:
            p[0] = int(p[2])
        except:
            p[0] = None

    def p_is_longer_than_expr(self, p):
        '''is_longer_than : IS_LONGER_THAN NUMBER
                      | IS_LONGER_THAN'''
        try:
            p[0] = int(p[2])
        except:
            p[0] = None

    def p_pca_parent_child_angle_expr(self, p):
        '''pca_parent_child_angle : PCA_PARENT_CHILD_ANGLE NUMBER
                              | PCA_PARENT_CHILD_ANGLE'''
        try:
            p[0] = float(p[2])
        except:
            p[0] = None


    def p_error(self, p):
        logging.error('Grammatical error, unexpectedly encountered token: {0}'.format(p))

        
        
    
