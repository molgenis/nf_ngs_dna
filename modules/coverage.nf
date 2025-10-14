process coverage {
    maxForks 20
    publishDir "$samples.projectResultsDir/coverage", mode: 'copy', overwrite: true
    
    module = ['HTSlib/1.16-GCCcore-11.3.0','BCFtools/1.16-GCCcore-11.3.0','gVCF2BED/1.1.0-GCCcore-11.3.0']

    input: 
    tuple val(samples), path(files)

    output: 
    path '*.csv'
	path '*.txt'

  shell:
	
  template 'coverage.sh'


}