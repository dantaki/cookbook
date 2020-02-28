#!/usr/env python
import numpy as np
from bed import toList,bedsortList
from pybedtools import BedTool
import itertools,sys
def count_stitch(cnv,probefh):
	to_stitch=[]
	first=''
	probes = BedTool(probefh).sort()
	cnvbed = BedTool(list(set(cnv))).sort(stream=True)
	cnv = toList(cnvbed)
	for i in xrange(len(cnv)):
		if i == 0: first=cnv[i]
		elif i > 0:
	       		(c1,s1,e1,cl1,id1,cf1) = first
			(c2,s2,e2,cl2,id2,cf2) = cnv[i]
			if cl1 != cl2: first = cnv[i]
			elif c1 != c2: first = cnv[i]
			else:
				g1 = int(e1)+1
				g2 = int(s2)-1
				if int(e1) == int(s2)-1:
					g1=int(e1)
					g2=int(s2)
			       	probe_spans=[]
				probe_spans.append(len(probes.intersect(BedTool(' '.join(map(str,(c1,s1,e1))),from_string=True),wa=True,u=True,stream=True)))
				probe_spans.append(len(probes.intersect(BedTool(' '.join(map(str,(c2,s2,e2))),from_string=True),wa=True,u=True,stream=True)))
				max_span = max(probe_spans)
				if len(probes.intersect(BedTool(' '.join(map(str,(c1,g1,g2))),from_string=True),wa=True,u=True,stream=True)) <= float(max_span)*0.5:
					to_stitch.append(i)
	to_stitch.sort()
	to_stitch = [[v[1] for v in vals] for _, vals in itertools.groupby(enumerate(to_stitch), key=lambda x: x[1] - x[0])]
	return len(to_stitch)
def sanders_stitch(cnv,probefh):
	stitch_idx=0
	#########################################################
	#	--------------------------------------		#
	#	Adapted from Sanders et.al Neuron 2015		#
	#	--------------------------------------		#
	#	Stitch gaps if the number of markers is <50%	#
	#	the number of markers of the larger cnv		#
	#	Stitching is applied recursively		#
	#########################################################
	if len(cnv)==0: return cnv
	if len(cnv)==1: return cnv
	else:
		to_stitch=[]
		cnv_pairs={}
		first=''
       		probes = BedTool(probefh).sort()
		cnvbed = BedTool(list(set(cnv))).sort(stream=True)
		cnv = toList(cnvbed)
		for i in xrange(len(cnv)):
			if i == 0: first=cnv[i]
			elif i > 0:
				(c1,s1,e1,cl1,id1,cf1) = first
				(c2,s2,e2,cl2,id2,cf2) = cnv[i]
				if cl1 != cl2:
					stitch_idx+=10
					first = cnv[i]
				elif c1 != c2:
					stitch_idx+=10
					first = cnv[i]
				else:
					g1 = int(e1)+1
					g2 = int(s2)-1
					if int(e1) == int(s2)-1:
						g1=int(e1)
						g2=int(s2)
					probe_spans=[]
					probe_spans.append(len(probes.intersect(BedTool(' '.join(map(str,(c1,s1,e1))),from_string=True),wa=True,u=True,stream=True)))
					probe_spans.append(len(probes.intersect(BedTool(' '.join(map(str,(c2,s2,e2))),from_string=True),wa=True,u=True,stream=True)))
					max_span = max(probe_spans)
					if len(probes.intersect(BedTool(' '.join(map(str,(c1,g1,g2))),from_string=True),wa=True,u=True,stream=True)) <= float(max_span)*0.5:
						to_stitch.append(stitch_idx)
						cnv_pairs[stitch_idx]=(first,cnv[i])
						stitch_idx+=1
		to_stitch.sort()
		to_stitch = [[v[1] for v in vals] for _, vals in itertools.groupby(enumerate(to_stitch), key=lambda x: x[1] - x[0])]
		stitched={}
		final={}
		for i in to_stitch:
			if len(i) == 1:
				(first,last) = cnv_pairs[i[0]]
				conf=[first[5],last[5]]  
				merged_conf = str(np.mean(map(float,conf)))
				final[(first[0],first[1],last[2],first[3],first[4],merged_conf)]=1
				stitched[first]=1
				stitched[last]=1
			else:
				first = cnv_pairs[i[0]][0]
				last = cnv_pairs[i[-1]][-1]
				conf_dict = {}
				for k in i:
					(f,s) = cnv_pairs[k]
					conf_dict[f]=f[5]
					conf_dict[s]=s[5]
					stitched[f]=1
					stitched[s]=1
				conf=[]
				for k in conf_dict: conf.append(conf_dict[k])
				merged_conf = str(np.mean(map(float,conf)))
				final[(first[0],first[1],last[2],first[3],first[4],merged_conf)]=1
		for i in cnv:
			if stitched.get(i) == None: final[i]=1
		return bedsortList([k for k in final])
def cnv_stitch(cnv,probefh):
	final=cnv
	while count_stitch(cnv,probefh) > 0:
		final = sanders_stitch(cnv,probefh)
		cnv = final
	return final
def main():
	cnv=[]
	# sys.argv[1] is the bed file of raw penn cnv calls (chr start end type ID conf) 
	with open(sys.argv[1],'r') as f:  
		for l in f: cnv.append(tuple(l.rstrip().split('\t')))
	cnv=cnv_stitch(cnv,'ipsc_snp') # ipsc_snp is a bed file of the SNP positions chrom pos pos 
	ofh=open(sys.argv[1]+'_stitched','w')
	for x in cnv: ofh.write('\t'.join(list(x))+'\n')
	ofh.close()
if __name__=="__main__": main()
