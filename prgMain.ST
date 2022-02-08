VAR_GLOBAL
  a0 at %X100.5 : bool; // spínač: vertikální                                                     X100.4
  a1 at %X100.4 : bool; // spínač: otáčení                                                        X100.5
  //a2 at %X10.2 : bool; // spínač: kleště                                                        X10.2
  a3 at %X100.6 : bool; // spínač: horizontální                                                   X10.3
  //a4 at %X10.1 : bool; // čítač:  horizontální                                                  X10.1

  s0 at %YW20 : uint; // slovo: vertikální                                                        YW20
  s1 at %YW4 : uint; // slovo: rotace                                                             YW4
  s2 at %YW26 : uint; // slovo: horizontální                                                      YW26

  w0 at %XL106 : udint; // inc: vertikální    //max cca 4000                                      XL106
  w1 at %XL14 : udint; // inc: rotace         //max cca 4300                                      XL14
  w2 at %XL116 : udint; // inc: horizontální  //max cca 4300
  
  m0 : udint := 4000;
  m1 : udint := 4300;
  m2 : udint := 4300;

  t0 at %X101.0 : bool; // test: 0
  t1 at %X101.1 : bool; // test: 1
  t2 at %X101.2 : bool; // test: 2
  t3 at %X101.3 : bool; // test: 3
  
  b0 at %Y33.3 : bool; // ventil           kleště: otevřít                                 ///DONE                 Y33.2
  b1 at %Y33.2 : bool; // kompresor        kleště: sevřít                ///DONE                 Y33.3
  b2 at %Y32.7 : bool; // horizontální motor: kupředu //RAMENO DOVNITR ///DONE  Y32.7
  b3 at %Y32.6 : bool; // horizontální motor: zpět //RAMENO VEN           ///DONE                 Y32.6
  b4 at %Y32.4 : bool; // vertikální motor: nahoru                        ///DONE                 Y32.5
  b5 at %Y32.5 : bool; // vertikální motor: dolu                          ///DONE                 Y32.4
  b6 at %Y33.0 : bool; // otáčení: cw                                     ///DONE                 Y33.2
  b7 at %Y33.1 : bool; // otáčení: ccw                                    ///DONE                 Y33.3
  //hl at %XL116 : udint;//                                                                         XL116
  inited : bool := 0;
  stav : uint := 0; //stav řízení
  //rth : R_TRIG; //R_TRIG pro horizontální čítač
  delay : TON;
END_VAR


FUNCTION init : bool
IF not a0 THEN
    ; //vertikální
    b4 := 1;
  ELSE
    b4 := 0;
  END_IF;
  IF not a1 THEN
    ; //rotace
    b6 := 1;
  ELSE
    b6 := 0;
  END_IF;
  (*
  IF not a2 THEN
    ; //kleště
    b0 := 1;
  ELSE
    b0 := 0;
  END_IF;
  *)
  IF not a3 THEN
    ; //horizontální
    b3 := 1;
  ELSE
    b3 := 0;
  END_IF;
  init := 1;
  IF a0 and a1 and a3 THEN
    ; //pokud jsou všechny spínače sepnuté vrať 1, jinak 0
    init := 1;
  ELSE
    init := 0;
  END_IF;
END_FUNCTION


FUNCTION blokit : bool;
  IF a0 THEN
    ;
    // nulování vert
    s0 := 2;
  END_IF;
  IF a1 THEN
    ; // nulování rot
    s1 := 2;
  END_IF;
  IF a3 THEN
    ;
    // nulování vert
    s2 := 2;
  END_IF;
  IF w0 >= m0 THEN
    ; //zablokuj klesání po vertikální ose
    b5 := 0;
  END_IF;
  IF a0 THEN
    ; //zablokuj stoupání po vertikání ose
    b4 := 0;
  END_IF;
  IF w1 >= m1 THEN
    ; //zablokuj rotaci ccw
    b7 := 0;
  END_IF;
  IF a1 THEN
    ; //zablokuj rotaci cw
    b6 := 0;
  END_IF;
  IF w2 >= m2 THEN
    ; //zablokuj horiz kupředu
    b2 := 0;
  END_IF;
  IF a3 THEN
    ; //zablokuj horiz zpět
    b3 := 0;
  END_IF;
  IF a3 THEN
    ; //blokování po horizontální ose
    b3 := 0;
  END_IF;
  (*IF hl >= 4300 THEN
    ;
    b2 := 0;
  END_IF;
  *)
END_FUNCTION


FUNCTION na_p_r : bool
  VAR_INPUT
    p : udint;
  END_VAR

  ;
  IF w1 <(p) THEN
    ;
    b7 := 1;
    b6 := 0;
    na_p_r := 0;
  ELSIF w1 >(p + 50) THEN
    ;
    b7 := 0;
    b6 := 1;
    na_p_r := 0;
  ELSE
    b7 := 0;
    b6 := 0;
    na_p_r := 1;
  END_IF;
END_FUNCTION


FUNCTION na_p_v : bool
  VAR_INPUT
    p : udint;
  END_VAR

  ;
  IF w0 <(p) THEN
    ;
    b5 := 1;
    b4 := 0;
    na_p_v := 0;
  ELSIF w0 >(p + 50) THEN
    ;
    b5 := 0;
    b4 := 1;
    na_p_v := 0;
  ELSE
    b5 := 0;
    b4 := 0;
    na_p_v := 1;
  END_IF;
END_FUNCTION


FUNCTION na_p_h : bool
  VAR_INPUT
    p : udint;
  END_VAR

  ;
  IF w2 <(p) THEN
    ;
    b2 := 1;
    b3 := 0;
    na_p_h := 0;
  ELSIF w2 >(p + 50) THEN
    ;
    b2 := 0;
    b3 := 1;
    na_p_h := 0;
  ELSE
    b2 := 0;
    b3 := 0;
    na_p_h := 1;
  END_IF;
END_FUNCTION


FUNCTION moveto : bool
  VAR_INPUT
    r, v : udint; //rotace, vertikální
    h : udint; //horizontální
    rs, as : uint; //stav reakce, aktivovat stav
    t : time; //zpoždění
  END_VAR

  ;
  IF stav = rs THEN
    ;
    IF na_p_r(r) and na_p_v(v) and na_p_h(h) THEN
      ;
      IF not delay.Q THEN
        ;
        delay(IN := 1, PT := t);
      ELSE
        stav := as;
        delay(IN := 0);
      END_IF;
    END_IF;
  END_IF;
END_FUNCTION


FUNCTION manual : bool
  b4 := t0 and t3;
  b5 := t0 and not t3; //rameno ven
  b3 := t1 and t3;
  b2 := t1 and not t3;
  b6 := t2 and t3;
  b7 := t2 and not t3;
END_FUNCTION

(*
FUNCTION pocitejHoriz : bool //funkce počítá jak daleko je vysunut robot po horizontální ose
  //rth.clk := a4; //vstup z horizontálního čítače jde do R_TRIG
  //rth();
  IF a3 THEN
    ; //pokud je horizontální tlačítko sepnuto, vynuluj čítač
    hl := 0;
  END_IF;
  IF rth.Q THEN
    ;
    IF b2 THEN
      ;
      hl := hl + 1;
    ELSE
      hl := hl - 1;
    END_IF;
  END_IF;
END_FUNCTION
*)

PROGRAM prgMain
  //pokud nebyla provedena initializace, tak ji proveď
  IF not inited THEN
    ;
    inited := init();
    s0 := 2;
    s1 := 2;
    s2 := 2;
  ELSE
    s0 := 1;
    s1 := 1;
    s2 := 1;
    //pocitejHoriz();
    //manual(); //manuální pohyb, pouze pro debug, využívá hodnoty "a#"

    moveto(m0/3,  0,  0,   0,   1,   T#0s);
    moveto(m0/3,  m1/2, 0,   1,   2,   T#0s);
    moveto(m0/3,  m1/2, m2/2,  2,   3,   T#1s);
    moveto(m0/3,  0,  0,   3,   4,   T#0s);
    moveto(m0/2,  0,  0,   4,   5,   T#0s);
    moveto(m0/2,  m1/2, 0,   5,   6,   T#0s);
    moveto(m0/2,  m1/2, m2/2,  6,   7,   T#1s);
    moveto(m0/2,  0,  0,   7,   8,   T#0s);
    moveto(m0/1,  0,  0,   8,   9,   T#0s);
    moveto(m0/1,  m1/2, 0,   9,   10,  T#0s);
    moveto(m0/1,  m1/2, m2/2,  10,  11,  T#1s);
    moveto(m0/1,  0,  0,   11,  0,   T#0s);

    (*
            if stav = 0 then;
               if not delay.Q then;
                  delay(IN:=1,PT:=T#1s);
               else
                   if na_p_r(200) and na_p_v(7500) then;
                        stav:=1;
                        delay(IN:=0);
                   end_if;
               end_if;
            end_if;

            if stav = 1 then;
               if not delay.Q then;
                  delay(IN:=1,PT:=T#1s);
               else
                   if na_p_v(0) then;
                      stav:=2;
                      delay(IN:=0);
                   end_if;
               end_if;
            end_if;

            if stav = 2 then;
               if not delay.Q then;
                  delay(IN:=1,PT:=T#1s);
               else
                   if na_p_r(4500) then;
                      stav:=3;
                      delay(IN:=0);
                   end_if;
               end_if;
            end_if;

            if stav = 3 then;
               if not delay.Q then;
                  delay(IN:=1,PT:=T#1s);
               else
               if na_p_r(8800) then;
                             stav:=0;
                             delay(IN:=0);
                  end_if;
               end_if;
            end_if;
            *)

  END_IF;
  blokit(); //sw limitace pohybu
END_PROGRAM

