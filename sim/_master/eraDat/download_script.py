#!/usr/bin/python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
'dataset' : 'interim',
'date'    : '19790101/to/20121231',
'stream'	 : 'oper',
'time'    : '00/06/12/18',
'grid'    : '0.75/0.75',
'step'    : '0',
'levtype' : 'pl',
'type'    : 'an',
'class'   : 'ei',
'param'   : '132',
'area'    : '46.925/7.075/46.075/10.175',
'levelist': '500/650/775/850/925/1000',
'target'  : 'rhpl.grb'
    })
