With Ada.Text_IO;           use Ada.Text_IO;
With Ada.Numerics.Discrete_Random;

procedure main is 
    subtype Number is Natural range 1..9;
    package Discrete_Random is new Ada.Numerics.Discrete_Random(number);
    use Discrete_Random;
    Rand : Generator;
    type T_Case is record
        Nb : Number;
        Visible : Boolean;
    end record;
    type Line is array (Number) of T_Case;
    type Grid is array (Number) of Line;
    type Possible_Nb is array(Number) of Boolean;


    procedure Put_Line(g : grid) 
    is
        H_Line : constant string(1..22):=(others=>'-');
    begin
        
        for y in 1..9 loop
            for x in 1..9 loop
               if not g(y)(x).Visible then
                   put(" -");
                else
                    put(Integer'Image(g(y)(x).Nb));
                end if;
                if x=3 or x=6 then
                    put(" |");
                end if;
            end loop;
            new_line;
            if y=3 or y=6 then
                Put_line(H_line);
            end if;
        end loop;
    end Put_Line;

    procedure Put_line(p : Possible_Nb) 
    is
    begin
        for e of p loop
            put(e'Image);
            put(";");
        end loop;
        new_line;
    end Put_line;

    procedure Put_line(p : Line) 
    is
    begin
        for e of p loop
            put(e.Nb'Image);
            put(";");
        end loop;
        new_line;
    end Put_line;


    function Find_Possible_Nb(G : Grid; x :  Number; y : Number; X_Cube : Number; Y_Cube : Number; nb_possibility : out Natural) return Possible_Nb
    is
        Possible_Numbers : Possible_Nb:=(others=>True);
    begin
        for i in 1..9 loop
           if G(y)(i).Visible then
              Possible_Numbers(G(y)(i).Nb):=False;
           end if;
           if G(i)(x).Visible then
                Possible_Numbers(G(i)(x).Nb):=False;
           end if;
        end loop;
        for i in 0..2 loop
            for k in 0..2 loop
                if G(Y_Cube+i)(X_Cube+k).Visible then
                    Possible_Numbers(G(Y_Cube+i)(X_Cube+k).Nb):=False;
                end if;
            end loop;
        end loop;
        nb_possibility:=0; 
        for v of Possible_Numbers loop
            if v then
                nb_possibility:=nb_possibility+1;
            end if;
        end loop;
        return Possible_Numbers;
    end Find_Possible_Nb;


    function Generate_Grid(G : in out grid; x : Number:=1; y : Number:=1) return Boolean
    is

        function Get_Case_In_Possibility(Possible_Numbers : Possible_Nb; Values_Already_tested : in out Possible_Nb) return T_Case
        is
            ind : Natural:=Random(Rand);
            i : Number :=1;
        begin
            while ind/=0 loop
                if Possible_Numbers(i) and not Values_Already_tested(i) then
                    ind:=ind-1;
                    if ind=0 then
                        Values_Already_tested(i):=True;
                        exit;
                    end if;
                end if;
                if i=9 then
                    i:=1;
                else 
                    i:=(i+1);
                end if;
            end loop;
            return (Nb=>i,Visible=>True);
        end Get_Case_In_Possibility;

        X_Cube : Number:=((x-1)/3)*3+1;
        Y_Cube : Number:=((y-1)/3)*3+1; 
        next_X : Number;
        next_y : Number;
        nb_possibility : Natural;
        Value_test :  Natural:=0;
        Possible_Numbers : Possible_Nb:=(others=>False);
        Values_Already_tested : Possible_Nb:=(others => False);

    begin
        Possible_Numbers:=Find_Possible_Nb(g,x,y,X_Cube,Y_Cube,nb_possibility);
        if nb_possibility=0 then
            return false;
        end if;
        G(y)(x):=Get_Case_In_Possibility(Possible_Numbers,Values_Already_tested);
        Value_test:=Value_test+1;

        if x=9 and y=9 then
            return true;
        end if;
        if x=9 then
            next_X:=1;
            next_y:=y+1;
        else
            next_X:=x+1;
            next_y:=y;
        end if;
        while not Generate_Grid(g,next_X,next_y) loop
            if  Value_test>=nb_possibility then
                G(y)(x):=(1,False);
                return false;
            else
                G(y)(x):=Get_Case_In_Possibility(Possible_Numbers,Values_Already_tested);
                Value_test:=Value_test+1;
            end if;
        end loop;
        return true;
    end Generate_Grid;

    function Playable_Grid(g :grid) return grid 
    is
        procedure Hide_Case(g : in out grid) is
            x : Number:=Random(Rand);
            y : Number:=Random(Rand);
        begin
            while not g(y)(x).Visible loop
                x:=Random(Rand);
                y:=Random(Rand);
            end loop;
            g(y)(x).Visible:=False;
        end Hide_Case;

        function Is_Complete(G : Grid) return boolean 
        is
        begin
           for y in 1..9 loop
               for x in 1..9 loop
                   if not g(y)(x).Visible then
                       return False;
                    end if;
                end loop;
            end loop;
            return True;
        end Is_Complete;
                    
        Playable_G : grid:=g;
        tmp_G : grid:=Playable_G;
        Test_Temp_G : grid:=Playable_G;
        Changed : boolean;
        X_Cube : Number;
        Y_Cube : Number;
        Possible_Numbers : Possible_Nb;
        Nb_Of_Possibility : Natural;
        Nb_Hiding_Cases : Natural:=0;
    begin
        while Is_Complete(Test_Temp_G) loop
           Playable_G:=tmp_G;  
           Hide_Case(tmp_G);
           Nb_Hiding_Cases:=Nb_Hiding_Cases+1;
           Test_Temp_G:=tmp_G;
           Changed:=True;
           while Changed loop
               Changed:=False;
               for y in 1..9 loop
                   for x in 1..9 loop
                       if not Test_Temp_G(y)(x).Visible then
                           X_Cube :=((x-1)/3)*3+1;
                           Y_Cube :=((y-1)/3)*3+1; 
                           Possible_Numbers:=Find_Possible_Nb(Test_Temp_G,x,y,X_Cube,Y_Cube,Nb_Of_Possibility);
                           if Nb_Of_Possibility=1 then
                               Test_Temp_G(y)(x).Visible:=True;
                               Changed:=True;
                            end if;
                        end if;
                    end loop;
                end loop;
            end loop;
        end loop;
        put_line("Number of Hiding Cases :"&Nb_Hiding_Cases'Image);
        put_line("Number of Visible Cases :"&Integer'Image(91-Nb_Hiding_Cases));
        new_line;
        return Playable_G;
        end Playable_Grid;

          



    g : grid:=(others => (others=>(Nb=>1,Visible=>False)));
    b :  boolean;
begin
    Reset(Rand);
    b:=Generate_Grid(g,1,1);
    if b then 
        Put_line("Solution Grid : ");
        new_line;
        Put_line(g);
        new_line;
        put_line("Playable_Grid : ");
        g:=Playable_Grid(g);
        Put_line(g);
    else
        put_line("generation failed...");
    end if;
end main;


