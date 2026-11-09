module skl_parser
  use skl_types
  implicit none
  private
  public :: parse_module
contains
  subroutine parse_module(stream, ast, status, message)
    type(token_stream_t),intent(in)::stream
    type(module_ast_t),intent(out)::ast
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    integer::p
    status=SKL_OK; message=''; p=1
    call skip_lines(stream,p)
    if(.not.match_word(stream,p,'MODULE')) then
      call fail(stream,p,'expected MODULE',status,message); return
    end if
    p=p+1
    if(.not.is_kind(stream,p,TOK_IDENT)) then
      call fail(stream,p,'expected module name',status,message); return
    end if
    ast%name=stream%items(p)%text; p=p+1
    do
      call skip_lines(stream,p)
      if(is_kind(stream,p,TOK_EOF)) exit
      if(match_word(stream,p,'FUNCTOR')) then
        call parse_functor(stream,p,ast,status,message)
        if(status/=SKL_OK) return
      else if(match_word(stream,p,'PIPELINE')) then
        call parse_pipeline(stream,p,ast,status,message)
        if(status/=SKL_OK) return
      else
        call fail(stream,p,'expected FUNCTOR, PIPELINE, or end of file',status,message); return
      end if
    end do
  end subroutine
  subroutine parse_functor(s,p,ast,status,message)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    type(module_ast_t),intent(inout)::ast
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    type(functor_decl_t)::f
    character(:),allocatable::field,field_value
    status=SKL_OK; message=''; f%line=s%items(p)%line; p=p+1
    if(.not.is_kind(s,p,TOK_IDENT)) then
      call fail(s,p,'expected functor name',status,message); return
    end if
    f%name=s%items(p)%text; p=p+1
    do
      call skip_lines(s,p)
      if(match_word(s,p,'END')) then
        p=p+1; exit
      else if(match_word(s,p,'INPUT').or.match_word(s,p,'OUTPUT')) then
        field=s%items(p)%text; p=p+1
        if(.not.match_symbol(s,p,':')) then
          call fail(s,p,'expected : after '//field,status,message); return
        end if
        p=p+1
        call collect_line(s,p,field_value)
        if(field=='INPUT') then
          f%input_type=field_value
        else
          f%output_type=field_value
        end if
      else if(match_word(s,p,'OPERATION').or.match_word(s,p,'REQUIRES').or.match_word(s,p,'ENSURES')) then
        field=s%items(p)%text; p=p+1
        if(.not.match_symbol(s,p,':')) then
          call fail(s,p,'expected : after '//field,status,message); return
        end if
        p=p+1
        call collect_block(s,p,field_value,status,message)
        if(status/=SKL_OK) return
        select case(field)
        case('OPERATION'); f%operation=field_value
        case('REQUIRES'); f%requires=field_value
        case('ENSURES'); f%ensures=field_value
        end select
      else
        call fail(s,p,'expected INPUT, OUTPUT, OPERATION, REQUIRES, ENSURES, or END',status,message); return
      end if
    end do
    if(.not.allocated(f%input_type).or..not.allocated(f%output_type).or..not.allocated(f%operation)) then
      status=SKL_ERR_PARSE
      message='functor '//f%name//' missing flags INPUT='//boolstr(allocated(f%input_type))// &
           ' OUTPUT='//boolstr(allocated(f%output_type))// &
           ' OPERATION='//boolstr(allocated(f%operation))
      return
    end if
    call append_functor(ast,f)
  end subroutine
  subroutine parse_pipeline(s,p,ast,status,message)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    type(module_ast_t),intent(inout)::ast
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    type(pipeline_decl_t)::pl
    status=SKL_OK; message=''; pl%line=s%items(p)%line; p=p+1
    if(.not.is_kind(s,p,TOK_IDENT)) then
      call fail(s,p,'expected pipeline name',status,message); return
    end if
    pl%name=s%items(p)%text; p=p+1
    do
      call skip_lines(s,p)
      if(match_word(s,p,'END')) then
        p=p+1; exit
      else if(match_word(s,p,'APPLY')) then
        p=p+1
        if(.not.is_kind(s,p,TOK_IDENT)) then
          call fail(s,p,'expected functor name after APPLY',status,message); return
        end if
        call append_step(pl,s%items(p)%text); p=p+1
        call skip_to_eol(s,p)
      else if(match_word(s,p,'VERIFY')) then
        p=p+1
        if(match_word(s,p,'ALL')) p=p+1
        call skip_to_eol(s,p)
      else
        call fail(s,p,'expected APPLY, VERIFY, or END',status,message); return
      end if
    end do
    call append_pipeline(ast,pl)
  end subroutine
  subroutine collect_line(s,p,value)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    character(:),allocatable,intent(out)::value
    value=''
    do while(.not.is_kind(s,p,TOK_NEWLINE).and..not.is_kind(s,p,TOK_EOF))
      if(len(value)>0) value=value//' '
      value=value//s%items(p)%text
      p=p+1
    end do
    if(is_kind(s,p,TOK_NEWLINE)) p=p+1
  end subroutine
  subroutine collect_block(s,p,value,status,message)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    character(:),allocatable,intent(out)::value
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    character(:),allocatable::line
    status=SKL_OK; message=''; value=''
    call skip_to_eol(s,p)
    do while(.not.is_kind(s,p,TOK_EOF))
      if(match_word(s,p,'END')) then
        p=p+1
        if(is_kind(s,p,TOK_NEWLINE)) p=p+1
        return
      end if
      call collect_line(s,p,line)
      if(len_trim(line)>0) then
        if(len(value)>0) value=value//' '
        value=value//trim(line)
      end if
    end do
    status=SKL_ERR_PARSE; message='unterminated block, expected END'
  end subroutine
  subroutine skip_lines(s,p)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    do while(is_kind(s,p,TOK_NEWLINE))
      p=p+1
    end do
  end subroutine
  subroutine skip_to_eol(s,p)
    type(token_stream_t),intent(in)::s
    integer,intent(inout)::p
    do while(.not.is_kind(s,p,TOK_NEWLINE).and..not.is_kind(s,p,TOK_EOF))
      p=p+1
    end do
    if(is_kind(s,p,TOK_NEWLINE)) p=p+1
  end subroutine
  logical function is_kind(s,p,k)
    type(token_stream_t),intent(in)::s
    integer,intent(in)::p,k
    is_kind=p>=1.and.p<=s%count
    if(is_kind) is_kind=s%items(p)%kind==k
  end function
  logical function match_word(s,p,w)
    type(token_stream_t),intent(in)::s
    integer,intent(in)::p
    character(*),intent(in)::w
    match_word=is_kind(s,p,TOK_IDENT)
    if(match_word) match_word=upper(s%items(p)%text)==w
  end function
  logical function match_symbol(s,p,w)
    type(token_stream_t),intent(in)::s
    integer,intent(in)::p
    character,intent(in)::w
    match_symbol=is_kind(s,p,TOK_SYMBOL)
    if(match_symbol) match_symbol=s%items(p)%text==w
  end function
  function upper(x) result(y)
    character(*),intent(in)::x
    character(len(x))::y
    integer::i,n
    y=x
    do i=1,len(x)
      n=iachar(y(i:i)); if(n>=97.and.n<=122) y(i:i)=achar(n-32)
    end do
  end function
  subroutine fail(s,p,why,status,message)
    type(token_stream_t),intent(in)::s
    integer,intent(in)::p
    character(*),intent(in)::why
    integer,intent(out)::status
    character(:),allocatable,intent(out)::message
    status=SKL_ERR_PARSE
    if(p<=s%count) then
      message=why//' at line '//num(s%items(p)%line)//', column '//num(s%items(p)%column)
    else
      message=why
    end if
  end subroutine
  function boolstr(v) result(x)
    logical,intent(in)::v
    character(:),allocatable::x
    if(v) then
      x='yes'
    else
      x='no'
    end if
  end function
  function num(i) result(x)
    integer,intent(in)::i
    character(:),allocatable::x
    character(24)::b
    write(b,'(i0)') i; x=trim(b)
  end function
end module skl_parser
