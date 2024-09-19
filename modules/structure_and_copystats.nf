process structure_and_copystats{

input: 
tuple val(samples), path(files)

output: 
  val(samples)
   
  shell:
  '''
    mkdir -m 2770 -p !{samples.projectResultsDir}/{alignment,qc,coverage,concordanceCheckSnps,variants/{gVCF,sv,cnv,additional_analysis}}
    rsync -av "!{samples.analysisFolder}/stats.tsv" "!{samples.projectResultsDir}/qc/"
    head -1 "!{samples.projectResultsDir}/qc/stats.tsv" > "!{samples.projectResultsDir}/qc/statsRenamed.tsv"
    rsync -av "!{params.samplesheet}" "!{samples.projectResultsDir}/"
  '''

}
