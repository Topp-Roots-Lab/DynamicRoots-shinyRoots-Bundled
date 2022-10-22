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

import sys, logging, os
from DynamicRootsParser import DynamicRootsParser
from DynamicRootsUtil import RootType

def get_base_name():
    rp = os.path.realpath(__file__)	
    bn = os.path.basename(rp).rsplit('.')[0]
    un = os.getlogin()
    return bn + '_' + un

if __name__ == '__main__':
    base_name = get_base_name()

    logging.basicConfig(filename=base_name + os.path.extsep + 'log',
                        level=logging.INFO,
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    
    parser = DynamicRootsParser()
    data = parser.parse(sys.stdin.read())
    for datum in data:
        if datum.kind != RootType.lateral:
            continue
        print('\t'.join([str(getattr(datum, k)) for k in vars(datum) if k != 'timesteps']))

    sys.exit(0)
        
