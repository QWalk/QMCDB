import json
import pandas as pd
import numpy as np

#Turn the JSON file from QWalk autogen into a table

dat=json.load(open("data.json"))

df={'timestep':[],
    'method':[],
    'multiplicity':[],
    'jastrow':[],
    'optimizer':[],
    'energy':[],
    'error':[] } 

for d in dat:
  hybrid=d['dft']['functional']['hybrid']
  multiplicity=d['total_spin']+1


  #get the DFT results
  dften=d['dft']['total_energy']
  df['timestep'].append(0.0)
  df['method'].append('DFT(PBE'+str(hybrid)+")")
  df['multiplicity'].append(multiplicity)
  df['jastrow'].append('none')
  df['optimizer'].append('none')
  df['energy'].append(dften)
  df['error'].append(0.0)

  #VMC 
  for jastrow in ['twobody','threebody']:
    df['timestep'].append(0.0)
    df['method'].append('VMC(PBE'+str(hybrid)+jastrow+")")
    df['multiplicity'].append(multiplicity)
    df['jastrow'].append(jastrow)
    df['optimizer'].append('energy')
    df['energy'].append(d['qmc']['energy_optimize'][jastrow]['energy'][-1])
    df['error'].append(d['qmc']['energy_optimize'][jastrow]['energy_err'][-1])
  

  #get the DMC results
  for res in d['qmc']['dmc']['results']:
    df['timestep'].append(res['timestep'])
    df['method'].append('DMC(PBE'+str(hybrid)+")")
    df['multiplicity'].append(multiplicity)
    df['jastrow'].append(res['jastrow'])
    df['optimizer'].append(res['optimizer'])
    df['energy'].append(res['results']['properties']['total_energy']['value'][0])
    df['error'].append(res['results']['properties']['total_energy']['error'][0])


df=pd.DataFrame(df)
#print(df)
import scipy
from scipy import stats

############################################################
#now we do timestep extrapolation 

dmc_extrap={'timestep':[],
            'method':[],
            'multiplicity':[],
            'jastrow':[],
            'optimizer':[],
            'energy':[],
            'error':[] } 
dmc=df[df['method'].str.contains('DMC') ]
#print(dmc)
pivot=['method','multiplicity','jastrow','optimizer']
groups=dmc.groupby(pivot)

for nm,group in groups:
  x=np.array(group['timestep'])
  y=np.array(group['energy'])
  print(x,y)
  a,b,r,p,err=stats.linregress(x,y)
  print(a,b,r,p,err)
  dmc_extrap['timestep'].append(0.0)
  for i,p in enumerate(pivot):
    dmc_extrap[p].append(nm[i])
  dmc_extrap['energy'].append(b)
  dmc_extrap['error'].append(np.array(group['error'])[0]) #estimate

dmc_extrap=pd.DataFrame(dmc_extrap)
#print(dmc_extrap)


##############################################################
#Estimate systematic errors (rough here for simplicity)
dmc_best={'method':[],
            'multiplicity':[],
            'energy':[],
            'error':[],
            'systematic_error':[],
            'basis':[]} 
pivot=['method','multiplicity']
groups=dmc_extrap.groupby(pivot)

for nm,group in groups:
  dmc_best['basis'].append('CBS')
  for i,p in enumerate(pivot):
    dmc_best[p].append(nm[i])
  dmc_best['energy'].append(np.mean(group['energy']))
  dmc_best['error'].append(np.sqrt(np.mean(group['error']**2)))
  dmc_best['systematic_error'].append(np.std(group['energy']))


#We should also go ahead and add the DFT(PBE25) results as well
dft=df[df['method'].str.contains('DFT')]
for d in dft.iterrows():
  for p in ['method','multiplicity','energy']:
    dmc_best[p].append(d[1][p])
  dmc_best['error'].append(0.0)
  dmc_best['systematic_error'].append(0.0)
  dmc_best['basis'].append('TZP')

#And the VMC 
vmc=df[df['method'].str.contains('VMC')]
for d in vmc.iterrows():
  for p in ['method','multiplicity','energy','error']:
    dmc_best[p].append(d[1][p])
  dmc_best['systematic_error'].append(0.0)
  dmc_best['basis'].append('TZP')


dmc_best=pd.DataFrame(dmc_best)
print(dmc_best)
dmc_best.to_csv('best.csv')
