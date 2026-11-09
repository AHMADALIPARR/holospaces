module gherkin_runner
  use iso_fortran_env, only: real64
  use skl_types
  use functor_runtime
  implicit none
  private
  public :: run_feature_file
contains
  subroutine run_feature_file(path,passed,failed,status,message)
    character(*),intent(in)::path
    integer,intent(out)::passed,failed,status
    character(:),allocatable,intent(out)::message
    character(2048)::line
    integer::u,ios,scenarios
    logical::in_scenario,scenario_ok,scenario_seen
    type(functor_registry_t)::registry
    character(:),allocatable::last_step
    passed=0; failed=0; status=SKL_OK; message=''; scenarios=0
    in_scenario=.false.; scenario_ok=.true.; scenario_seen=.false.; last_step=''
    open(newunit=u,file=path,status='old',action='read',iostat=ios)
    if(ios/=0) then
      status=SKL_ERR_IO; message='cannot open feature file: '//trim(path); return
    end if
    call initialize_registry(registry)
    do
      read(u,'(A)',iostat=ios) line
      if(ios/=0) exit
      if(index(adjustl(line),'Scenario:')==1.or.index(adjustl(line),'Scenario Outline:')==1) then
        if(in_scenario) then
          if(scenario_ok) then
            passed=passed+1
          else
            failed=failed+1
          end if
        end if
        scenarios=scenarios+1; in_scenario=.true.; scenario_ok=.true.; scenario_seen=.true.
      else if(in_scenario) then
        if(index(adjustl(line),'Given ')==1.or.index(adjustl(line),'When ')==1.or. &
           index(adjustl(line),'Then ')==1.or.index(adjustl(line),'And ')==1.or. &
           index(adjustl(line),'But ')==1) then
          call evaluate_step(trim(adjustl(line)),registry,scenario_ok,last_step)
        end if
      end if
    end do
    close(u)
    if(in_scenario) then
      if(scenario_ok) then
        passed=passed+1
      else
        failed=failed+1
      end if
    end if
    if(.not.scenario_seen) then
      status=SKL_ERR_PARSE; message='no Scenario found in feature file'
    else if(failed>0) then
      status=SKL_ERR_EXEC; message='one or more Gherkin scenarios failed'
    end if
  end subroutine
  subroutine evaluate_step(step,registry,ok,last_step)
    character(*),intent(in)::step
    type(functor_registry_t),intent(in)::registry
    logical,intent(inout)::ok
    character(:),allocatable,intent(inout)::last_step
    integer::st
    character(:),allocatable::msg
    real(real64)::v(4)
    real(real64),allocatable::out(:)
    if(index(step,'ADD functor is registered')>0.or.index(step,'registry is initialized')>0) then
      last_step=step
    else if(index(step,'execute ADD with vector [2, 4, 6, 8]')>0) then
      v=[2.0_real64,4.0_real64,6.0_real64,8.0_real64]
      call execute_functor(registry,'ADD',v,out,st,msg)
      ok=ok.and.st==SKL_OK
      if(st==SKL_OK) ok=ok.and.size(out)==2.and.all(abs(out-[6.0_real64,14.0_real64])<1.0e-12_real64)
    else if(index(step,'execution status should be successful')>0) then
      ok=ok
    else if(index(step,'execute ADD with vector [2, 4, 6]')>0) then
      v(1:3)=[2.0_real64,4.0_real64,6.0_real64]
      call execute_functor(registry,'ADD',v(1:3),out,st,msg)
      ok=ok.and.st/=SKL_OK
    else if(index(step,'execution status should be unsuccessful')>0) then
      ok=ok
    else if(index(step,'execute UNKNOWN')>0) then
      call execute_functor(registry,'UNKNOWN',[1.0_real64],out,st,msg)
      ok=ok.and.st==SKL_ERR_RESOLVE
    else if(index(step,'resolver should reject execution')>0) then
      ok=ok
    else if(index(step,'result should equal [6, 14]')>0) then
      ok=ok
    else
      ! Unrecognized steps are failures, never silently treated as passing.
      ok=.false.
    end if
  end subroutine
end module gherkin_runner
