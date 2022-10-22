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

__all__ = ['RootType', 'Record', 'Timestep', 'Point3D']

from collections import namedtuple as __namedtuple
from enum import Enum as __Enum

class RootType(__Enum):
    primary = 1
    crown   = 2
    seminal = 3
    lateral = 4
    unknown = 0

    def __str__(self):
        return self.name

    def __repr__(self):
        return type(self).__name__ + '.' + self.name

class Record(__namedtuple('Record', ['branch', 'kind', 'fork_depth', 'h_order', 'timesteps'])):
    
    __slots__ = ()
    
    __doc__ = '''Instances of this class hold the contents of one line of the textual output file 
produced by DynamicRoots.'''

class __MaybeAllNoneMixin(object):
    
    __doc__ = '''This mixin class can be used to determine whether all fields in a namedtuple
have the value None.'''
    
    def empty(self):
        rc = True
        for field in self._fields:
            if getattr(self, field) is not None:
                rc = False
                break 
        return rc
                 

class Timestep(__namedtuple('Timestep', ['volume', 'length', 'geod_depth', 'vert_depth',
                                         'tip_xyz', 'curvedness', 'av_radius', 'pca_vert_angle',
                                         'n_children', 'is_longer_than', 'pca_parent_child_angle']),
                                         __MaybeAllNoneMixin):
    
    __slots__ = ()
    
    __doc__ = '''Instances of this class hold the data for individual root at a given timestep.'''


class Point3D(__namedtuple('Point3D', ['x', 'y', 'z']), __MaybeAllNoneMixin):

    __slots__ = ()

    __doc__ = '''A point in 3D.'''


