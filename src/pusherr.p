

unit pusherr;
     interface
	     uses  MemTypes, QuickDraw, OSIntf, ToolIntf, PackIntf, PrintTraps, PasLibIntf,
		    globals,help,text,cmmnds1; 

    
		procedure pushError(parm:longint);
		

   implementation

procedure pushError(parm:longint);
(*************************************************)
(*                                               *)
(*      called when an invariant is determined   *)
(*      to have a value outside of its current   *)
(*      bounds.  usually implies an invalid rule *)
(*      is being used.                           *)
(*                                               *)
(*************************************************)
var op:char;
    rulenumber,zcopy:longint;
    rzcopy:real;
    undo,sperror:boolean;
	

procedure pause;	
begin
  write(sysm:1,'   Hit return >');
  readln;
  writeln(sysm:1);
end;
	
	
	
	
begin
  noescap:=true;
  undo:=undoable[copyptr];
  zcopy:=z;
  rzcopy:=rz;
  name:=parameter[parm];
  writeln(sysm:1);
  writeln(sysm:1,'  OUT-OF-RANGE ERROR!!!');
  if undo then
       begin
         write(sysm:1,'    The system will be reset (to Table');
         writeln(numtables-1:3,').')
       end
    else writeln(sysm:1,'   The system must be reinitialized.');
  writeln(sysm:1,'    An inconsistency was detected during execution of');
  rulenumber:=convert(rule);
  if rulenumber > 0 then writeln(sysm:1,'    Theorem ',rulenumber:3,', where')
          else writeln(sysm:1,'    Temporary Theorem ',-rulenumber:2,', where');
  writeln(sysm:1);
  write(sysm:1,'         /');
  if parm in bparam then
        begin
          write('The value of "',name:6,'" is: ');
          if min[parm]=max[parm] then
                  if min[parm]=0 then writeln('"no",')
                                 else writeln('"yes",')
                else writeln('"not determined",');
          write(sysm:1,'         \The  proposed  value  is: ');
          if z=0 then writeln('"no".')
                 else
                   if z=1 then writeln('"yes".')
                          else writeln(z:4,' .');
        end
      else
        begin
          if parm=spectr then
                 if lammin=lammax then 
                     begin
                       write('The value of "',name:6,'" is:');
                       if lammax < infinity then writeln(lammax:9:3,' ,')
                                            else writeln(udt:6,' ,');
                     end
                   else
                     begin
                       write('The range of "',name:6,'" is: [');
                       write(lammin:9:3,',');
                       if lammax < infinity then writeln(lammax:9:3,'],')
                                            else writeln(udt:6,'],');
                     end
                   else
                     if min[parm]=max[parm] then 
                       begin
                         write('The value of "',name:6,'" is:');
                         writeln(max[parm]:6,' ,');
                       end
                      else
                        begin
                          write('The range of "',name:6,'" is: [');
                          write(min[parm]:6,',');
                          if max[parm] < infinity then writeln(max[parm]:6,'],')
                                                  else writeln(udt:6,'],');
                        end;
          write(sysm:1,'         \The  proposed  value  is: ');
          if parm=spectr then rWriteUdt(rz) 
                         else iWriteUdt(z,5);
          writeln(' .');
        end;
  primary:=numtables;
  moveCurToCopyI(copyptr);
  op:='h';
  while op <> blk do
      begin
        writeln(sysm:1);
        writeln(sysm:1,'    Exit by hitting return, or by typing:');
        writeln(sysm:1);
        writeln(sysm:1,'            1 - list the current Table,');
        writeln(sysm:1,'            2 - print the "rulestack",');
        writeln(sysm:1,'            3 - print the violated theorem,');
        writeln(sysm:1,'            4 - print another theorem,');
(*{$IFC pass2}
        if undo then
         begin
           writeln(sysm:1,'            5 - "trace" the violated invariant, or');
           writeln(sysm:1,'            6 - "trace" another invariant.');
         end;
{$ENDC}*)
        write(sysm:1,'           ?');
        read(op);
        if op=escp then
                 begin
                   op:=blk;
                   readln;
                 end;
        if op<>blk then
            begin
              readln;
              name:=parameter[parm];
              if op = '1' then printTable(numtables,numtables-1) 
                 else if op = '2' then printRuleStack
                   else if op = '3' then
                              begin
                                writeln(sysm:1);
                                if rulenumber > 0 then
                                     writeln(sysm:1,'   Theorem ',rulenumber:3,':')
                                  else
                                     writeln(sysm:1,'   Temporary Theorem ',-rulenumber:2,':');
                                writeln(sysm:1);
                                write(sysm:1,'          ');
                                if rulenumber > 0 then ruletext(rulenumber,0)
                                                  else printTempTheorem(-rulenumber);
                                writeln;
                                writeln(sysm:1);
                              end
                    else if op = '4' then 
                             begin
                               sperror:=perror;
                               perror:=false;
                               printTheoremText;
                               perror:=sperror;
                               writeln(sysm:1);
                             end
(*{$IFC pass2}				   
                   else  if (undo) and ((op = '5') or (op = '6')) then
                         if op = '5' then 
                                   begin
                                     z:=zcopy;
                                     rz:=rzcopy;
                                     traceIt(0);
									 writeln(sysm:1);
                                   end
                              else 
                                begin
                                  perrorother:=true;
                                  traceIt(0);
                                  perrorother:=false;
								  writeln(sysm:1);
                                end
{$ENDC}	*)				 
                        else writeln(sysm:1,' Try again.');
			  pause;
            end;
       end;
   if undo then
        begin
          resetTable;
          error(200);
        end
      else error(-19);
   perror:=false;
   noescap:=false;
   stars;
end;

end.
