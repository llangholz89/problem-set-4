#! /usr/bin/env bash

#Files: Note, files were unzipped before beginning
reference='/Users/loganlangholz/Documents/class_files/Graduate/Spring_2016/Genome_analysis/Projects/problem-set-4/data/hg19.chr1.fa'
fastq='/Users/loganlangholz/Documents/class_files/Graduate/Spring_2016/Genome_analysis/Projects/problem-set-4/data/factorx.chr1.fq'
chr_sizes='/Users/loganlangholz/Documents/class_files/Graduate/Spring_2016/Genome_analysis/Projects/problem-set-4/data/hg19.chrom.sizes'

#Build index and align reads:
bowtie2-build -f $reference chr1_index
bowtie2 -x chr1_index -U $fastq \
    | samtools sort > output.bam

#Create bedGraph, then BigWig fiels:
bedtools genomecov -ibam output.bam -bg > output.bg
bedGraphToBigWig output.bg $chr_sizes output.bw

#call peaks:
macs2 callpeak -t output.bam --nomodel -n factorx

#shuffle peaks and take only top 1000, add slop (50bp each side), put in new file
shuf factorx_summits.bed | head -n 1000 \
    | awk 'BEGIN {OFS="\t"} {print $1, $2-50, $3+50, $4, $5}' \
    > factorx_shuf_peaks.bed

# Get Fasta sequence for the shuffled peaks:
bedtools getfasta -fi $reference -bed factorx_shuf_peaks.bed -fo factorx.fa

# Plug fasta file into meme to get motifs
meme factorx.fa -nmotifs 1 -maxw 20 -minw 8 -dna -maxsize 1000000
meme-get-motif -id 1 < meme_out/meme.txt

