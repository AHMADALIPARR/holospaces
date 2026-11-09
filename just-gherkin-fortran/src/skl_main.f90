program skl
  use iso_fortran_env, only: real64
  use skl_types
  use skl_lexer
  use skl_parser
  use functor_runtime
  use gherkin_runner
  implicit none
  integer::argc,status,passed,failed
  character(512)::arg,path
  character(:),allocatable::source,message
  type(token_stream_t)::tokens
  type(module_ast_t)::ast
  type(functor_registry_t)::registry
  real(real64),allocatable::output(:)
  real(real64)::sample(4)
  argc=command_argument_count()
  if(argc<1) then
    call usage(); stop 2
  end if
  call get_command_argument(1,arg)
  select case(trim(arg))
  case('parse','verify')
    if(argc<2) then
      write(*,'(A)') 'error: source file required'; stop 2
    end if
    call get_command_argument(2,path)
    call read_file(trim(path),source,status,message)
    if(status/=SKL_OK) call die(message)
    call lex_source(source,tokens,status,message)
    if(status/=SKL_OK) call die(message)
    call parse_module(tokens,ast,status,message)
    if(status/=SKL_OK) call die(message)
    call validate_ast(ast,status,message)
    if(status/=SKL_OK) call die(message)
    if(trim(arg)=='parse') then
      write(*,'(A)') 'PARSE OK: module '//ast%name
      if(allocated(ast%functors)) write(*,'(A,I0)') 'FUNCTORS: ',size(ast%functors)
      if(allocated(ast%pipelines)) write(*,'(A,I0)') 'PIPELINES: ',size(ast%pipelines)
    else
      write(*,'(A)') 'VERIFY OK: syntax, AST, declarations, and pipeline references'
    end if
  case('test')
    if(argc<2) then
      write(*,'(A)') 'error: feature file required'; stop 2
    end if
    call get_command_argument(2,path)
    call run_feature_file(trim(path),passed,failed,status,message)
    write(*,'(A,I0,A,I0)') 'SCENARIOS PASSED: ',passed,' FAILED: ',failed
    if(status/=SKL_OK) call die(message)
  case('demo')
    call initialize_registry(registry)
    sample=[2.0_real64,4.0_real64,6.0_real64,8.0_real64]
    call execute_functor(registry,'ADD',sample,output,status,message)
    if(status/=SKL_OK) call die(message)
    write(*,'(A,*(f8.2,1x))') 'ADD RESULT: ',output
  case default
    call usage(); stop 2
  end select
contains
  subroutine read_file(filename,contents,st,msg)
    character(*),intent(in)::filename
    character(:),allocatable,intent(out)::contents,msg
    integer,intent(out)::st
    character(4096)::buf
    integer::unit,io
    contents=''; msg=''; st=SKL_OK
    open(newunit=unit,file=filename,status='old',action='read',iostat=io)
    if(io/=0) then
      st=SKL_ERR_IO; msg='cannot open source file: '//trim(filename); return
    end if
    do
      read(unit,'(A)',iostat=io) buf
      if(io<0) exit
      if(io>0) then
        st=SKL_ERR_IO; msg='error reading source file'; close(unit); return
      end if
      contents=contents//trim(buf)//achar(10)
    end do
    close(unit)
  end subroutine
  subroutine die(msg)
    character(*),intent(in)::msg
    write(*,'(A)') 'ERROR: '//msg
    stop 1
  end subroutine
  subroutine usage()
    write(*,'(A)') 'SKL Fortran runtime'
    write(*,'(A)') '  skl parse <file.skl>'
    write(*,'(A)') '  skl verify <file.skl>'
    write(*,'(A)') '  skl test <feature.feature>'
    write(*,'(A)') '  skl demo'
  end subroutine
end program skl
