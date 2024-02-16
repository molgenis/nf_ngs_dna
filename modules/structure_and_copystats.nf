process structure_and_copystats{

input: 
tuple val(samples), path(files)

output: 
  val(samples)
   
  shell:
  '''
    mkdir -p !{samples.projectResultsDir}/{alignment,qc,coverage,variants/{gVCF,sv,cnv}}
    rsync -av "!{samples.analysisFolder}/stats.tsv" "!{samples.projectResultsDir}/qc/"
    rsync -av "!{params.samplesheet}" "!{samples.projectResultsDir}/"
  '''

}
