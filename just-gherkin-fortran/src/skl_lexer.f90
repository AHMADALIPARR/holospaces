module skl_lexer
  use skl_types
  implicit none
  private
  public :: lex_source
contains
  subroutine lex_source(source, stream, status, message)
    character(*), intent(in) :: source
    type(token_stream_t), intent(out) :: stream
    integer, intent(out) :: status
    character(:), allocatable, intent(out) :: message
    integer :: i,line,col,n,start
    character :: ch
    type(token_t) :: t
    status=SKL_OK; message=''; line=1; col=1; i=1; n=len(source)
    do while(i<=n)
      ch=source(i:i)
      if(ch==' '.or.ch==achar(9).or.ch==achar(13)) then
        i=i+1; col=col+1
      else if(ch==achar(10)) then
        t%kind=TOK_NEWLINE; t%text=achar(10); t%line=line; t%column=col
        call append_token(stream,t); i=i+1; line=line+1; col=1
      else if(ch=='#') then
        do while(i<=n)
          if(source(i:i)==achar(10)) exit
          i=i+1; col=col+1
        end do
      else if(is_alpha(ch).or.ch=='_') then
        start=i
        do while(i<=n)
          if(.not.is_alnum(source(i:i)).and.source(i:i)/='_') exit
          i=i+1; col=col+1
        end do
        t%kind=TOK_IDENT; t%text=source(start:i-1); t%line=line; t%column=col-(i-start)
        call append_token(stream,t)
      else if(is_digit(ch).or.(ch=='.'.and.i<n.and.is_digit(source(i+1:i+1)))) then
        start=i
        do while(i<=n)
          if(.not.(is_digit(source(i:i)).or.source(i:i)=='.'.or.source(i:i)=='e'.or. &
               source(i:i)=='E'.or.source(i:i)=='+'.or.source(i:i)=='-')) exit
          if((source(i:i)=='+'.or.source(i:i)=='-').and.i>start) then
            if(source(i-1:i-1)/='e'.and.source(i-1:i-1)/='E') exit
          end if
          i=i+1; col=col+1
        end do
        t%kind=TOK_NUMBER; t%text=source(start:i-1); t%line=line; t%column=col-(i-start)
        call append_token(stream,t)
      else if(ch=='"'.or.ch=="'") then
        start=i; i=i+1; col=col+1
        do while(i<=n)
          if(source(i:i)==ch) exit
          if(source(i:i)==achar(10)) exit
          i=i+1; col=col+1
        end do
        if(i>n) then
          status=SKL_ERR_LEX; message='unterminated string at line '//itoa(line); return
        end if
        if(source(i:i)/=ch) then
          status=SKL_ERR_LEX; message='unterminated string at line '//itoa(line); return
        end if
        t%kind=TOK_STRING; t%text=source(start+1:i-1); t%line=line; t%column=col-(i-start)
        call append_token(stream,t); i=i+1; col=col+1
      else
        t%kind=TOK_SYMBOL; t%text=ch; t%line=line; t%column=col
        call append_token(stream,t); i=i+1; col=col+1
      end if
    end do
    t%kind=TOK_EOF; t%text=''; t%line=line; t%column=col
    call append_token(stream,t)
  end subroutine
  logical function is_alpha(c)
    character, intent(in)::c
    is_alpha=(c>='A'.and.c<='Z').or.(c>='a'.and.c<='z')
  end function
  logical function is_digit(c)
    character, intent(in)::c
    is_digit=c>='0'.and.c<='9'
  end function
  logical function is_alnum(c)
    character, intent(in)::c
    is_alnum=is_alpha(c).or.is_digit(c)
  end function
  function itoa(i) result(s)
    integer,intent(in)::i
    character(:),allocatable::s
    character(24)::b
    write(b,'(i0)') i
    s=trim(b)
  end function
end module skl_lexer
