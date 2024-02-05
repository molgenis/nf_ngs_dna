process process_dragen_trendanalysis {
publishDir "$samples.projectResultsDir/qc/statistics/", mode: 'copy', overwrite: true

input: 
    tuple val(samples), path(files)

output:
    tuple val(samples), path(dragenInfoCSV),path(dragenCSV)

shell:
  
  dragenInfoCSV="${samples.project}.Dragen_runinfo.csv"
  dragenCSV="${samples.project}.Dragen.csv"

  template 'process_dragen_trendanalysis.sh'
}