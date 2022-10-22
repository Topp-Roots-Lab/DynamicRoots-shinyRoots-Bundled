import numpy as np
from skimage.io import imread, imsave
from glob import glob
import sys
import os

idir = sys.argv[1]
odir = sys.argv[2]

gts = sorted(glob(idir+'/*.png'))

for y in range(len(gts)//4):
    print("%d of %d"%(y,len(gts)//4))

    avimg = 0.
    for k in range(4):
        img = np.float32(imread(gts[y*4+k]))/1.#/255.
        #img = np.maximum(1e-4,np.minimum(1.-1e-4,img))
        #img = np.log(img) - np.log(1.-img)
        sz,sx = (img.shape[0]//4)*4,(img.shape[1]//4)*4
        for i in range(4):
            for j in range(4):
                avimg = avimg + img[i:sz:4,j:sx:4]
    avimg = avimg/64.
    #avimg = np.exp(avimg) / (1.+np.exp(avimg))
    if y == 0:
        outs = np.zeros((len(gts)//4,avimg.shape[0],avimg.shape[1]),np.uint8)
    outs[y,...] = np.uint8(avimg*255.)

data = np.ascontiguousarray(outs,dtype=np.uint8)

# Save
if not os.path.exists(odir):
       os.makedirs(odir)
z, x, y = data.shape
for i in range(z):
    imsave(odir+('/%04d.png'%i),np.uint8(data[i, ]))