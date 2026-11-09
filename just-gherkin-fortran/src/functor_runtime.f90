module functor_runtime
  use iso_fortran_env, only: real64
  use skl_types
  implicit none
  private
  public :: functor_registry_t, initialize_registry, register_functor, &
       execute_functor, validate_ast, execute_pipeline
  abstract interface
    subroutine functor_proc(input,output,status)
      import real64
      real(real64),intent(in)::input(:)
      real(real64),allocatable,intent(out)::output(:)
      integer,intent(out)::status
    end subroutine
  end interface
  type :: registry_entry_t
    character(:),allocatable::name
    procedure(functor_proc),pointer,nopass::invoke=>null()
  end type
  type :: functor_registry_t
    type(registry_entry_t),allocatable::entries(:)
  end type
contains
  subroutine initialize_registry(registry)
    type(functor_registry_t),intent(out)::registry
    procedure(functor_proc),pointer::p_add,p_norm,p_identity
    allocate(registry%entries(0))
    p_add=>add_vectors; p_norm=>normalize_vector; p_identity=>identity_vector
    call register_functor(registry,'ADD',p_add)
    call register_functor(registry,'NORMALIZE',p_norm)
    call register_functor(registry,'IDENTITY',p_identity)
  end subroutine
  subroutine register_functor(registry,name,proc,status)
    type(functor_registry_t),intent(inout)::registry
    character(*),intent(in)::name
    procedure(functor_proc),pointer,intent(in)::proc
    integer,optional,intent(out)::status
    type(registry_entry_t),allocatable::tmp(:)
    integer::i,n,st
    st=SKL_OK; n=size(registry%entries)
    do i=1,n
      if(registry%entries(i)%name==name) st=SKL_ERR_RESOLVE
    end do
    if(st==SKL_OK) then
      allocate(tmp(n+1)); if(n>0) tmp(:n)=registry%entries
      tmp(n+1)%name=trim(name); tmp(n+1)%invoke=>proc
      call move_alloc(tmp,registry%entries)
    end if
    if(present(status)) status=st
  end subroutine
  subroutine execute_functor(registry,name,input,output,status,message)
    type(functor_registry_t),intent(in)::registry
    character(*),intent(in)::name
    real(real64),intent(in)::input(:)
    real(real64),allocatable,intent(out)::output(:)
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    integer::i
    status=SKL_ERR_RESOLVE; message='unregistered functor: '//trim(name)
    do i=1,size(registry%entries)
      if(registry%entries(i)%name==name) then
        if(.not.associated(registry%entries(i)%invoke)) then
          status=SKL_ERR_RESOLVE; message='null functor procedure: '//trim(name); return
        end if
        call registry%entries(i)%invoke(input,output,status)
        if(status==SKL_OK) then
          message=''
        else
          message='functor execution failed: '//trim(name)
        end if
        return
      end if
    end do
  end subroutine
  subroutine validate_ast(ast,status,message)
    type(module_ast_t),intent(in)::ast
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    integer::i,j
    status=SKL_OK; message=''
    if(.not.allocated(ast%name)) then
      status=SKL_ERR_SEMANTIC; message='module has no name'; return
    end if
    if(allocated(ast%functors)) then
      do i=1,size(ast%functors)
        if(ast%functors(i)%input_type/='VECTOR [ F64 ]'.and.ast%functors(i)%input_type/='VECTOR[F64]') then
          status=SKL_ERR_SEMANTIC; message='unsupported input type in '//ast%functors(i)%name; return
        end if
        if(ast%functors(i)%output_type/='VECTOR [ F64 ]'.and.ast%functors(i)%output_type/='VECTOR[F64]') then
          status=SKL_ERR_SEMANTIC; message='unsupported output type in '//ast%functors(i)%name; return
        end if
        do j=i+1,size(ast%functors)
          if(ast%functors(i)%name==ast%functors(j)%name) then
            status=SKL_ERR_SEMANTIC; message='duplicate functor: '//ast%functors(i)%name; return
          end if
        end do
        if(len_trim(ast%functors(i)%operation)==0) then
          status=SKL_ERR_SEMANTIC; message='empty operation in '//ast%functors(i)%name; return
        end if
      end do
    end if
    if(allocated(ast%pipelines)) then
      do i=1,size(ast%pipelines)
        if(.not.allocated(ast%pipelines(i)%steps)) cycle
        do j=1,size(ast%pipelines(i)%steps)
          if(.not.has_functor(ast,ast%pipelines(i)%steps(j)%functor_name)) then
            status=SKL_ERR_SEMANTIC
            message='pipeline '//ast%pipelines(i)%name//' references undeclared functor '// &
                 ast%pipelines(i)%steps(j)%functor_name
            return
          end if
        end do
      end do
    end if
  end subroutine
  logical function has_functor(ast,name)
    type(module_ast_t),intent(in)::ast
    character(*),intent(in)::name
    integer::i
    has_functor=.false.
    if(.not.allocated(ast%functors)) return
    do i=1,size(ast%functors)
      if(ast%functors(i)%name==name) has_functor=.true.
    end do
  end function
  subroutine execute_pipeline(registry,ast,pipeline_name,input,output,status,message)
    type(functor_registry_t),intent(in)::registry
    type(module_ast_t),intent(in)::ast
    character(*),intent(in)::pipeline_name
    real(real64),intent(in)::input(:)
    real(real64),allocatable,intent(out)::output(:)
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    real(real64),allocatable::current(:),next(:)
    integer::i,j
    status=SKL_ERR_SEMANTIC; message='pipeline not found: '//trim(pipeline_name)
    if(.not.allocated(ast%pipelines)) return
    do i=1,size(ast%pipelines)
      if(ast%pipelines(i)%name==pipeline_name) then
        current=input
        if(.not.allocated(ast%pipelines(i)%steps)) then
          output=current; status=SKL_OK; message=''; return
        end if
        do j=1,size(ast%pipelines(i)%steps)
          call execute_functor(registry,ast%pipelines(i)%steps(j)%functor_name,current,next,status,message)
          if(status/=SKL_OK) return
          call move_alloc(next,current)
        end do
        output=current; status=SKL_OK; message=''; return
      end if
    end do
  end subroutine
  subroutine add_vectors(input,output,status)
    real(real64),intent(in)::input(:)
    real(real64),allocatable,intent(out)::output(:)
    integer,intent(out)::status
    status=SKL_ERR_EXEC
    if(mod(size(input),2)/=0) return
    allocate(output(size(input)/2)); output=input(1::2)+input(2::2); status=SKL_OK
  end subroutine
  subroutine normalize_vector(input,output,status)
    real(real64),intent(in)::input(:)
    real(real64),allocatable,intent(out)::output(:)
    integer,intent(out)::status
    real(real64)::magnitude
    status=SKL_ERR_EXEC; magnitude=sqrt(sum(input*input))
    if(magnitude<=tiny(magnitude)) return
    allocate(output(size(input))); output=input/magnitude; status=SKL_OK
  end subroutine
  subroutine identity_vector(input,output,status)
    real(real64),intent(in)::input(:)
    real(real64),allocatable,intent(out)::output(:)
    integer,intent(out)::status
    allocate(output(size(input))); output=input; status=SKL_OK
  end subroutine
end module functor_runtime
