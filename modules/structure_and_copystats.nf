process structure_and_copystats{

input: 
tuple val(samples), path(files)
   
  shell:
  '''
    mkdir -p !{samples.projectResultsDir}/{alignment,qc,variants/{gVCF,sv,cnv}}
    rsync -av "!{samples.analysisFolder}/stats.tsv" "!{samples.projectResultsDir}/qc/"
  '''

}