process run_dragen_solo_trupath {
  maxForks 1
  label 'run_dragen_solo_trupath'
  input: 
  tuple val(samples), path(fastqList)
  
  output:
  val(x)
  
  shell:
  x="dummy"
  
  template 'run_dragen_solo_trupath.sh'
}