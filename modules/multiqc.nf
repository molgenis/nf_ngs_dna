process multiqc {

input: 
  tuple val(samples), path(files)
   
  shell:
  '''
		ml purge
		ml multiqc/1.35-GCCcore-11.3.0
    multiqc "!{samples.projectResultsDir}/qc/"
    rsync -av multiqc_report.html "!{samples.projectResultsDir}/"
  '''
}