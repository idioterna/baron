Program AirWar;

Uses Crt,Graph,Drivers,Fonts;


Const
     DUp          = 0;
     DDn          = 4;
     DLt          = 6;
     DRt          = 2;
     DUpLt        = 7;
     DUpRt        = 1;
     DDnLt        = 5;
     DDnRt        = 3;

Type
    BombRec = Record
            X,Y:Integer;
            XS,YS:Integer;
            Dropped:Boolean;
            Dead:Boolean;
    end;
    Aircraft = Record
             Dir:Byte;
             X,Y:Integer;
             Sc:Word;
             S:Byte;
             Dead:Boolean;
             Landed:Boolean;
             Ammo:Byte;
             BombsLeft:Byte;
             Bomb:Array[1..5] of BombRec;
             FieldCrushed:Boolean;
             FieldHit:Byte;
    end;

Procedure DrawBottom;
Var I:Word;
    R,RP:Integer;
Begin
     Randomize;
     SetColor(Green);
     RP:=0;
     For I:=0 to 640 do
     Begin
          If I mod 5=0 then
          Begin
               R:=Random(10)+1;
               Line(I,470-R,I-5,470-RP);
               RP:=R;
          end;
     end;
     SetFillStyle(SolidFill,Green);
     FloodFill(0,479,Green);
     SetColor(LightGray);
     For I:=470 downto 459 do
     Line(50,I,195,I);
     For I:=470 downto 459 do
     Line(440,I,585,I);
end;

Procedure Explode(X,Y:Word);
Var I:Byte;
    XT:Array[1..50] of ShortInt;
    YT:Array[1..50] of ShortInt;
Begin
     SetColor(Yellow);
     Randomize;
     For I:=1 to 50 do
     Begin
          XT[I]:=25-Random(50);
          YT[I]:=25-Random(50);
          Line(X,Y,X+XT[I],Y+YT[I]);
          Sound(Random(100)+1);
     end;
     Delay(30);
     SetColor(Black);
     For I:=1 to 50 do
     Begin
          Line(X,Y,X+XT[I],Y+YT[I]);
          Sound(Random(100)+1);
     end;
end;

Procedure DrawPlane(X,Y,Dir:Word);
Begin
     Case Dir of
          DUp:Begin
                   Line(X-1,Y-4,X+1,Y-4);
                   Line(X-1,Y-3,X+1,Y-3);
                   Line(X-5,Y-2,X+5,Y-2);
                   Line(X-5,Y-1,X+5,Y-1);
                   Line(X-1,Y+0,X+1,Y+0);
                   Line(X-1,Y+1,X+1,Y+1);
                   Line(X-1,Y+2,X+1,Y+2);
                   Line(X-2,Y+3,X+2,Y+3);
          end;
          DDn:Begin
                   Line(X-2,Y-4,X+2,Y-4);
                   Line(X-1,Y-3,X+1,Y-3);
                   Line(X-1,Y-2,X+1,Y-2);
                   Line(X-1,Y-1,X+1,Y-1);
                   Line(X-5,Y+0,X+5,Y+0);
                   Line(X-5,Y+1,X+5,Y+1);
                   Line(X-1,Y+2,X+1,Y+2);
                   Line(X-1,Y+3,X+1,Y+3);
          end;
          DLt:Begin
                   Line(X+4,Y-2,X+5,Y-2);
                   Line(X+3,Y-1,X+5,Y-1);
                   Line(X-4,Y,X+5,Y);
                   Line(X-5,Y+1,X+5,Y+1);
                   Line(X-3,Y+2,X+5,Y+2);
          end;
          DRt:Begin
                   Line(X-4,Y-2,X-5,Y-2);
                   Line(X-3,Y-1,X-5,Y-1);
                   Line(X+4,Y,X-5,Y);
                   Line(X+5,Y+1,X-5,Y+1);
                   Line(X+3,Y+2,X-5,Y+2);
          end;
          DUpLt:Begin
                   Line(X-5,Y-4,X+3,Y+2);
                   Line(X-4,Y-3,X+2,Y+3);
                   Line(X-3,Y-4,X+4,Y+1);
                   Line(X+5,Y-1,X+4,Y-2);
                   Line(X+4,Y-0,X+2,Y-2);
          end;
          DUpRt:Begin
                   Line(X+5,Y-4,X-3,Y+2);
                   Line(X+4,Y-3,X-2,Y+3);
                   Line(X+3,Y-4,X-4,Y+1);
                   Line(X-5,Y-1,X-4,Y-2);
                   Line(X-4,Y-0,X-2,Y-2);
          end;
          DDnLt:Begin
                   Line(X-5,Y+4,X+3,Y-1);
                   Line(X-4,Y+3,X+4,Y-2);
                   Line(X-3,Y+4,X+4,Y-0);
                   Line(X+3,Y-4,X+2,Y-3);
                   Line(X+3,Y-3,X+1,Y-1);
          end;
          DDnRt:Begin
                   Line(X+5,Y+4,X-3,Y-1);
                   Line(X+4,Y+3,X-4,Y-2);
                   Line(X+3,Y+4,X-4,Y-0);
                   Line(X-3,Y-4,X-2,Y-3);
                   Line(X-3,Y-3,X-1,Y-1);
          end;
     end;
end;

Procedure DrawBomb(X,Y:Integer);
Begin
     SetColor(Red);
     RectAngle(X-1,Y-1,X+1,Y+1);
end;

Procedure ClearBomb(X,Y:Integer);
Begin
     SetColor(Black);
     RectAngle(X-1,Y-1,X+1,Y+1);
end;


Procedure ClearPlane(X,Y:Word);
Var I:Integer;
Begin
     SetColor(Black);
     For I:=-5 to 4 do Line(X-5,Y+I,X+5,Y+I);
end;

Procedure Terminate;
Begin
     Nosound;
     CloseGraph;
     WriteLn('Bye!');
     Halt(0);
end;

Var Gd,Gm:Integer;
    A:Aircraft;
    B:Aircraft;
    Ch:Char;
    G:Byte;
    I:Integer;

Function PlaneInSight(X1,Y1,X2,Y2,Dir:Word):Boolean;
Var Angle:Integer;
    I,J:Word;
    X,Y:Integer;
    S,C:Real;
Begin
     Case Dir of
          DUp:Angle:=270;
          DDn:Angle:=90;
          DLt:Angle:=180;
          DRt:Angle:=0;
          DUpLt:Angle:=225;
          DUpRt:Angle:=315;
          DDnLt:Angle:=135;
          DDnRt:Angle:=45;
     end;
     For I:=1 to 5 do
     Begin
          Sound(100);
          Delay(1);
          NoSound;
     end;
     S:=Sin((Angle*2*PI)/360);
     C:=Cos((Angle*2*PI)/360);
     For I:=1 to 100 do
     Begin
          X:=Round(C*I);
          Y:=Round(S*I);
          If I mod 5=0 then
          Begin
               PutPixel(X1+X,Y1+Y,White);
               Delay(1);
          end;
          If (X1+X<X2+3) and (X1+X>X2-3) and (Y1+Y<Y2+3) and (Y1+Y>Y2-3) then
          Begin
               PlaneInSight:=True;
               Exit;
               For J:=1 to 64 do
               Begin
                    SetColor(J);
                    Line(X1+X,Y1+Y,X1,Y1);
               end;
          end;
     end;
     For I:=1 to 64 do
     Begin
          SetColor(I);
          Line(X1+X,Y1+Y,X1,Y1);
     end;
     PlaneInSight:=False;
end;

Procedure UpDateAmmoA;
Begin
     SetColor(Black);
     Line(1,1,55,1);
     SetColor(LightRed);
     Line(1,1,A.Ammo*5,1);
end;

Procedure UpDateAmmoB;
Begin
     SetColor(Black);
     Line(1,3,55,3);
     SetColor(Yellow);
     Line(1,3,B.Ammo*5,3);
end;

Procedure UpDateSpeedA;
Begin
     SetColor(Black);
     Line(60,1,60+62,1);
     SetColor(LightRed);
     Line(60,1,60+A.S*5,1);
end;

Procedure UpDateSpeedB;
Begin
     SetColor(Black);
     Line(60,3,60+62,3);
     SetColor(Yellow);
     Line(60,3,60+B.S*5,3);
end;

Procedure UpDateFieldA;
Begin
     SetColor(Black);
     Line(160,1,160+62,1);
     SetColor(LightRed);
     Line(160,1,160+A.FieldHit*5,1);
end;

Procedure UpDateFieldB;
Begin
     SetColor(Black);
     Line(160,3,160+62,3);
     SetColor(Yellow);
     Line(160,3,160+B.FieldHit*5,3);
end;

Procedure UpDateBombA;
Begin
     SetColor(Black);
     Line(260,1,260+62,1);
     SetColor(LightRed);
     Line(260,1,260+A.BombsLeft*5,1);
end;

Procedure UpDateBombB;
Begin
     SetColor(Black);
     Line(260,3,260+62,3);
     SetColor(Yellow);
     Line(260,3,260+B.BombsLeft*5,3);
end;

Function IS(X:Word):String;
Var S:String;
Begin
     Str(X,S);
     IS:=S;
end;

Label Beginning;

Begin
     if RegisterBGIdriver(@EGAVGADriverProc) < 0 then begin end;
     if RegisterBGIfont(@GothicFontProc) < 0 then begin end;
     if RegisterBGIfont(@SansSerifFontProc) < 0 then begin end;
     if RegisterBGIfont(@SmallFontProc) < 0 then begin end;
     if RegisterBGIfont(@TriplexFontProc) < 0 then begin end;

     Gd:=VGA;
     Gm:=VGAHi;
     InitGraph(Gd,Gm, '');
     If GraphResult<>GrOK then
     Begin
          WriteLn('Graphics Error: '+GraphErrorMsg(GraphResult));
          Halt(1);
     end;
     A.Sc:=0;
     B.Sc:=0;
     Beginning:
     A.FieldCrushed:=False;
     B.FieldCrushed:=False;
     A.FieldHit:=0;
     B.FieldHit:=0;
     For I:=1 to 5 do
     Begin
          A.Bomb[I].Dropped:=False;
          B.Bomb[I].Dropped:=False;
          A.Bomb[I].Dead:=False;
          B.Bomb[I].Dead:=False;
     end;
     A.BombsLeft:=5;
     B.BombsLeft:=5;
     SetBkColor(Black);
     ClearDevice;
     SetTextJustify(CenterText,CenterText);
     SetColor(Red);
     SetTextStyle(DefaultFont,HorizDir,5);
     OutTextXY(GetMaxX div 2,GetMaxY div 2-50,'THE RED BARON');
     SetTextStyle(DefaultFont,HorizDir,3);
     SetColor(Blue);
     OutTextXY(GetMaxX div 2,GetMaxY div 2,'Result '+IS(A.Sc)+':'+IS(B.Sc));
     SetColor(Brown);
     SetTextStyle(DefaultFont,HorizDir,1);
     OutTextXY(GetMaxX div 2,GetMaxY div 2+50,'By Jure Koren, Idiot Softwarez, Inc.');
     SetTextStyle(DefaultFont,HorizDir,1);
     SetTextJustify(LeftText,TopText);
     OutTextXY(100,GetMaxY div 2+70,'                    Red player:            Yellow player:');
     OutTextXY(100,GetMaxY div 2+90,'faster:                W                         Up');
     OutTextXY(100,GetMaxY div 2+100,'slower:                S                        Down');
     OutTextXY(100,GetMaxY div 2+110,'counter-clockwise:     A                        Left');
     OutTextXY(100,GetMaxY div 2+120,'clockwise:             D                        Right');
     OutTextXY(100,GetMaxY div 2+130,'fire cannon:         Space                      Enter');
     OutTextXY(100,GetMaxY div 2+140,'drop bombs:            Q                      Backspace');
     OutTextXY(100,GetMaxY div 2+150,'airfield:            left                       right');
     OutTextXY(80,GetMaxY div 2+180,'To reload land - only on your own field and with your nose up!');
     Repeat Until KeyPressed;
     Ch:=ReadKey;
     ClearDevice;
     SetBkColor(Blue);
     DrawBottom;
     Randomize;
     B.X:=Random(500)+70;
     B.Y:=Random(150)+50;
     A.X:=Random(500)+70;
     A.Y:=Random(150)+50;
     A.Dir:=Random(8);
     B.Dir:=Random(8);
     A.Dead:=False;
     B.Dead:=False;
     A.S:=5;
     B.S:=5;
     A.Ammo:=10;
     B.Ammo:=10;
     UpDateAmmoA;
     UpDateAmmoB;
     UpDateBombA;
     UpDateBombB;
     UpDateFieldA;
     UpDateFieldB;
     G:=0;
     Repeat
           G:=G+1;
           If G=4 then G:=0;
           If (A.Y=454) and ((A.X>50) and (A.X<195)) and Not A.Landed
           and Not A.FieldCrushed then
           Begin
                If ((A.Dir=DUpLt) or (A.Dir=DUpRt)) then
                Begin
                     A.Landed:=True;
                     If A.Dir=DUpLt then A.Dir:=DLt else If A.Dir=DUpRt then A.Dir:=DRt;
                     A.S:=1;
                     A.Y:=454;
                end;
           end;
           If A.Landed then
           Begin
                If (A.X>185) and (A.S=1) then A.Dir:=DLt;
                If (A.X<60) and (A.S=1) then A.Dir:=DRt;
                If Not ((A.X>50) and (A.X<195)) then
                Begin
                     A.Landed:=False;
                     A.S:=0;
                end;
                If ((A.Dir=DUpLt) or (A.Dir=DUpRt)) and (A.S>2) then
                Begin
                     A.Landed:=False;
                end;
                If (A.Dir<>DLt) and (A.Dir<>DRt) and A.Landed then
                Begin
                     A.Landed:=False;
                     A.S:=0;
                     A.Dir:=DDn;
                end;
                If A.Dir=DRt then A.X:=A.X+A.S else If A.Dir=DLt then A.X:=A.X-A.S;
           end;
           If Not A.Dead and Not A.Landed then
           Begin
                Case A.Dir of
                     DDn:Begin
                              A.Y:=A.Y+A.S;
                              If G=0 then If A.S<10 then A.S:=A.S+2;
                     end;
                     DUp:Begin
                              A.Y:=A.Y-A.S;
                              If G=0 then If A.S>0 then A.S:=A.S-1;
                     end;
                     DLt:Begin
                              A.X:=A.X-A.S;
                              If A.S<3 then A.Y:=A.Y+1;
                     end;
                     DRt:Begin
                              A.X:=A.X+A.S;
                              If A.S<3 then A.Y:=A.Y+1;
                     end;
                     DUpLt:Begin
                                If A.S<=3 then A.Y:=A.Y+2;
                                A.X:=A.X-A.S;
                                A.Y:=A.Y-A.S;
                     end;
                     DUpRt:Begin
                                If A.S<=3 then A.Y:=A.Y+2;
                                A.X:=A.X+A.S;
                                A.Y:=A.Y-A.S;
                     end;
                     DDnLt:Begin
                                A.X:=A.X-A.S;
                                A.Y:=A.Y+A.S;
                                If G=0 then If A.S<8 then A.S:=A.S+1;
                     end;
                     DDnRt:Begin
                                A.X:=A.X+A.S;
                                A.Y:=A.Y+A.S;
                                If G=0 then If A.S<8 then A.S:=A.S+1;
                     end;
                end;
           end;
           If A.Y>455 then
           Begin
                B.Sc:=B.Sc+1;
                Explode(A.X,A.Y);
                Nosound;
                Delay(1000);
                Goto Beginning;
           end;
           If A.Y<20 then
           Begin
                If A.Dir=DUp then A.Dir:=DDn;
                If A.Dir=DUpRt then A.Dir:=DDnRt;
                If A.Dir=DUpLt then A.Dir:=DDnLt;
           end;
           If A.X>630 then
           Begin
                A.X:=10;
           end;
           If A.X<10 then
           Begin
                A.X:=630;
           end;
           If (B.Y=454) and ((B.X>440) and (B.X<585)) and Not B.Landed
           and Not B.FieldCrushed then
           Begin
                If ((B.Dir=DUpLt) or (B.Dir=DUpRt)) then
                Begin
                     B.Landed:=True;
                     If B.Dir=DUpLt then B.Dir:=DLt else If B.Dir=DUpRt then B.Dir:=DRt;
                     B.S:=1;
                     B.Y:=454;
                end;
           end;
           If B.Landed then
           Begin
                If (B.X<450) and (B.S=1) then B.Dir:=DRt;
                If (B.X>575) and (B.S=1) then B.Dir:=DLt;
                If Not ((B.X<585) and (B.X>440)) then
                Begin
                     B.Landed:=False;
                     B.S:=0;
                end;
                If ((B.Dir=DUpLt) or (B.Dir=DUpRt)) and (B.S>2) then
                Begin
                     B.Landed:=False;
                end;
                If (B.Dir<>DLt) and (B.Dir<>DRt) and B.Landed then
                Begin
                     B.Landed:=False;
                     B.S:=0;
                     B.Dir:=DDn;
                end;
                If B.Dir=DRt then B.X:=B.X+B.S else If B.Dir=DLt then B.X:=B.X-B.S;
           end;
           If Not B.Dead and Not B.Landed then
           Begin
                Case B.Dir of
                     DDn:Begin
                              B.Y:=B.Y+B.S;
                              If G=0 then If B.S<10 then B.S:=B.S+2;
                     end;
                     DUp:Begin
                              B.Y:=B.Y-B.S;
                              If G=0 then If B.S>0 then B.S:=B.S-1;
                     end;
                     DLt:Begin
                              B.X:=B.X-B.S;
                              If B.S<3 then B.Y:=B.Y+1;
                     end;
                     DRt:Begin
                              B.X:=B.X+B.S;
                              If B.S<3 then B.Y:=B.Y+1;
                     end;
                     DUpLt:Begin
                                If B.S<=3 then B.Y:=B.Y+2;
                                B.X:=B.X-B.S;
                                B.Y:=B.Y-B.S;
                     end;
                     DUpRt:Begin
                                If B.S<=3 then B.Y:=B.Y+2;
                                B.X:=B.X+B.S;
                                B.Y:=B.Y-B.S;
                     end;
                     DDnLt:Begin
                                B.X:=B.X-B.S;
                                B.Y:=B.Y+B.S;
                                If G=0 then If B.S<8 then B.S:=B.S+1;
                     end;
                     DDnRt:Begin
                                B.X:=B.X+B.S;
                                B.Y:=B.Y+B.S;
                                If G=0 then If B.S<8 then B.S:=B.S+1;
                     end;
                end;
           end;
           If B.Y>455 then
           Begin
                A.Sc:=A.Sc+1;
                Explode(B.X,B.Y);
                Nosound;
                Delay(1000);
                Goto Beginning;
           end;
           If B.Y<20 then
           Begin
                If B.Dir=DUp then B.Dir:=DDn;
                If B.Dir=DUpRt then B.Dir:=DDnRt;
                If B.Dir=DUpLt then B.Dir:=DDnLt;
           end;
           If B.X>630 then
           Begin
                B.X:=10;
           end;
           If B.X<10 then
           Begin
                B.X:=630;
           end;
           If (A.X>B.X-5) and (A.X<B.X+5) and (A.Y>B.Y-4) and (A.Y<B.Y+4) then
           Begin
                Explode(A.X,A.Y);
                Explode(B.X,B.Y);
                NoSound;
                Delay(1000);
                Goto Beginning;
           end;
           If B.Dead then
           Begin
                If B.X<20 then B.X:=B.X+5;
                If B.X>620 then B.X:=B.X-5;
                B.Y:=B.Y+5;
                B.X:=B.X-5+Random(10)+1;
                If G=0 then B.Dir:=B.Dir+1;
                If B.Dir=8 then B.Dir:=0;
           end;
           If A.Dead then
           Begin
                If A.X<20 then A.X:=A.X+5;
                If A.X>620 then A.X:=A.X-5;
                A.Y:=A.Y+5;
                A.X:=A.X-5+Random(10)+1;
                If G=0 then A.Dir:=A.Dir+1;
                If A.Dir=8 then A.Dir:=0;
           end;
           SetColor(LightRed);
           DrawPlane(A.X,A.Y,A.Dir);
           SetColor(Yellow);
           DrawPlane(B.X,B.Y,B.Dir);
           If KeyPressed then
           Begin
                Ch:=UpCase(ReadKey);
                If Not A.Dead then
                Begin
                     Case Ch of
                          'D':If A.Dir=7 then A.Dir:=0 else A.Dir:=A.Dir+1;
                          'A','Y':If A.Dir=0 then A.Dir:=7 else A.Dir:=A.Dir-1;
                          'W':If A.S<10 then A.S:=A.S+1;
                          'S':If A.S>0 then A.S:=A.S-1;
                          'Q':Begin
                                   I:=1;
                                   While I<=5 do
                                   Begin
                                       If Not A.Bomb[I].Dropped and Not A.Bomb[I].Dead then
                                       Begin
                                            A.Bomb[I].Dropped:=True;
                                            If A.Dir IN [DLt,DUpLt,DDnLt] then A.Bomb[I].XS:=-A.S
                                            else A.Bomb[I].XS:=A.S;
                                            If A.Dir IN [DDn,DUp] then A.Bomb[I].XS:=0;
                                            A.Bomb[I].YS:=A.S;
                                            A.Bomb[I].X:=A.X;
                                            A.Bomb[I].Y:=A.Y+5;
                                            A.BombsLeft:=A.BombsLeft-1;
                                            UpDateBombA;
                                            I:=6;
                                       end;
                                       I:=I+1;
                                   end;
                          end;
                     end;
                     If (A.S>3) and A.Landed then A.S:=3;
                end;
                If Ch=#27 then Terminate;
                If (Ch=#13) and (B.Ammo>0) then
                Begin
                     B.Ammo:=B.Ammo-1;
                     UpDateAmmoB;
                     If PlaneInSight(B.X,B.Y,A.X,A.Y,B.Dir) then A.Dead:=True;
                end;
                If (Ch=#32) and (A.Ammo>0) then
                Begin
                     A.Ammo:=A.Ammo-1;
                     UpDateAmmoA;
                     If PlaneInSight(A.X,A.Y,B.X,B.Y,A.Dir) then B.Dead:=True;
                end;
                If Ch=#8 then
                Begin
                     I:=1;
                     While I<=5 do
                     Begin
                         If Not B.Bomb[I].Dropped and Not B.Bomb[I].Dead then
                         Begin
                              Begin
                                   B.Bomb[I].Dropped:=True;
                                   If B.Dir IN [DLt,DUpLt,DDnLt] then B.Bomb[I].XS:=-B.S
                                   else B.Bomb[I].XS:=B.S;
                                   If B.Dir IN [DDn,DUp] then B.Bomb[I].XS:=0;
                                   B.Bomb[I].YS:=B.S;
                                   B.Bomb[I].X:=B.X;
                                   B.Bomb[I].Y:=B.Y+5;
                                   B.BombsLeft:=B.BombsLeft-1;
                                   UpDateBombB;
                                   I:=6;
                              end;
                         end;
                         I:=I+1;
                     end;
                end;
                If Ch=#0 then
                Begin
                     Ch:=ReadKey;
                     If Not B.Dead then
                     Begin
                          Case Ch of
                               #75:If B.Dir=0 then B.Dir:=7 else B.Dir:=B.Dir-1;
                               #77:If B.Dir=7 then B.Dir:=0 else B.Dir:=B.Dir+1;
                               #72:If B.S<10 then B.S:=B.S+1;
                               #80:If B.S>0 then B.S:=B.S-1;
                          end;
                     end;
                     If (B.S>3) and B.Landed then B.S:=3;
                end;
           end;
           If (A.S=0) and Not A.Landed then A.Dir:=DDn;
           If (B.S=0) and Not B.Landed then B.Dir:=DDn;
           If (A.S=0) and A.Landed then
           Begin
                A.Ammo:=10;
                A.BombsLeft:=5;
                For I:=1 to 5 do
                Begin
                     A.Bomb[I].Dead:=False;
                     A.Bomb[I].Dropped:=False;
                end;
                UpDateAmmoA;
                UpDateBombA;
           end;
           If (B.S=0) and B.Landed then
           Begin
                B.BombsLeft:=5;
                For I:=1 to 5 do
                Begin
                     B.Bomb[I].Dead:=False;
                     B.Bomb[I].Dropped:=False;
                end;
                B.Ammo:=10;
                UpDateAmmoB;
                UpDateBombB;
           end;
           UpDateSpeedA;
           UpDateSpeedB;
           For I:=1 to 5 do
           Begin
                If A.Bomb[I].Dropped and Not A.Bomb[I].Dead then
                ClearBomb(A.Bomb[I].X,A.Bomb[I].Y);
                If B.Bomb[I].Dropped and Not B.Bomb[I].Dead then
                ClearBomb(B.Bomb[I].X,B.Bomb[I].Y);
                If A.Bomb[I].Dropped and Not A.Bomb[I].Dead then
                Begin
                     If (G=0) and (A.Bomb[I].XS>0) then A.Bomb[I].XS:=A.Bomb[I].XS-1;
                     If (G=0) and (A.Bomb[I].YS<12) then A.Bomb[I].YS:=A.Bomb[I].YS+1;
                     A.Bomb[I].X:=A.Bomb[I].X+A.Bomb[I].XS;
                     A.Bomb[I].Y:=A.Bomb[I].Y+A.Bomb[I].YS;
                     if (A.Bomb[I].X > 630) then A.Bomb[I].X := 10;
                     if (A.Bomb[I].X < 10) then A.Bomb[I].X := 630;
                end;
                If B.Bomb[I].Dropped and Not B.Bomb[I].Dead then
                Begin
                     If (G=0) and (B.Bomb[I].XS>0) then B.Bomb[I].XS:=B.Bomb[I].XS-1;
                     If (G=0) and (B.Bomb[I].YS<12) then B.Bomb[I].YS:=B.Bomb[I].YS+1;
                     B.Bomb[I].X:=B.Bomb[I].X+B.Bomb[I].XS;
                     B.Bomb[I].Y:=B.Bomb[I].Y+B.Bomb[I].YS;
                     if (B.Bomb[I].X > 630) then B.Bomb[I].X := 10;
                     if (B.Bomb[I].X < 10) then B.Bomb[I].X := 630;
                end;
                If A.Bomb[I].Dropped and Not A.Bomb[I].Dead then
                DrawBomb(A.Bomb[I].X,A.Bomb[I].Y);
                If B.Bomb[I].Dropped and Not B.Bomb[I].Dead then
                DrawBomb(B.Bomb[I].X,B.Bomb[I].Y);
                If A.Bomb[I].Dropped and Not A.Bomb[I].Dead then
                Begin
                     If A.Bomb[I].Y>455 then
                     Begin
                          Explode(A.Bomb[I].X,A.Bomb[I].Y);
                          Nosound;
                          A.Bomb[I].Dead:=True;
                          If  (A.Bomb[I].X<B.X+20) and (A.Bomb[I].X>B.X-20)
                          and (A.Bomb[I].Y<B.Y+20) and (A.Bomb[I].Y>B.Y-20) then B.Dead:=True;
                          If (A.Bomb[I].X<195) and (A.Bomb[I].X>50) and (A.FieldHit<10) then Inc(A.FieldHit);
                          If (A.Bomb[I].X<585) and (A.Bomb[I].X>440) and (B.FieldHit<10) then Inc(B.FieldHit);
                          If A.FieldHit>3 then A.FieldCrushed:=True;
                          If B.FieldHit>3 then B.FieldCrushed:=True;
                          UpDateFieldA;
                          UpDateFieldB;
                     end;
                end;
                If B.Bomb[I].Dropped and Not B.Bomb[I].Dead then
                Begin
                     If B.Bomb[I].Y>455 then
                     Begin
                          Explode(B.Bomb[I].X,B.Bomb[I].Y);
                          Nosound;
                          B.Bomb[I].Dead:=True;
                          If  (B.Bomb[I].X<A.X+20) and (B.Bomb[I].X>A.X-20)
                          and (B.Bomb[I].Y<A.Y+20) and (B.Bomb[I].Y>A.Y-20) then A.Dead:=True;
                          If (B.Bomb[I].X<585) and (B.Bomb[I].X>440) and (B.FieldHit<10) then Inc(B.FieldHit);
                          If (B.Bomb[I].X<195) and (B.Bomb[I].X>50) and (A.FieldHit<10) then Inc(A.FieldHit);
                          If A.FieldHit>3 then A.FieldCrushed:=True;
                          If B.FieldHit>3 then B.FieldCrushed:=True;
                          UpDateFieldA;
                          UpDateFieldB;
                     end;
                end;
           end;
           Delay(70);
           ClearPlane(A.X,A.Y);
           ClearPlane(B.X,B.Y);
           SetColor(Random(2)+7);
           If A.Dead then Circle(A.X,A.Y,Random(5)+1);
           If B.Dead then Circle(B.X,B.Y,Random(5)+1);
     Until False;
end.
