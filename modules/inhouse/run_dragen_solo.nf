process run_dragen_solo {
  maxForks 1
  label 'run_dragen_solo'
  input: 
  tuple val(samples), path(fastqList)
  
  output:
  val(x)
  
  shell:
  x="dummy"
  
  template 'run_dragen_solo.sh'
}