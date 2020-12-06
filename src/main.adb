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


    function Generate_Grid(G : in out grid; x : Number:=1; y : Number:=1) return Boolean
    is
        X_Cube : Number:=((x-1)/3)*3+1;
        Y_Cube : Number:=((y-1)/3)*3+1; 

        function Generate_Case(x :  Number; y : Number; nb_possibility : out Natural) return T_Case
        is
            ind : Natural;
            i : Number;
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
            ind:=Random(Rand);
            i:=1;
            nb_possibility:=0; 
            for v of Possible_Numbers loop
                if v then
                    nb_possibility:=nb_possibility+1;
                end if;
            end loop;
            if nb_possibility=0 then
                return (Nb=>1, Visible=>False);
            end if;

            while ind/=0 loop
                if Possible_Numbers(i) then
                    ind:=ind-1;
                    if ind=0 then
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
        end Generate_Case;

        next_X : Number;
        next_y : Number;
        last_nb : T_Case;
        nb_possibility : Natural;
        Value_test :  Natural:=0;
        Values_Already_tested : Possible_Nb:=(others => False);
    begin
        last_nb:=Generate_Case(x,y,nb_possibility);
        Values_Already_tested(last_nb.Nb):=True;
        G(y)(x):=last_nb;
        Value_test:=Value_test+1;
        if nb_possibility=0 then
            return false;
        end if;

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
                declare
                    new_nb : T_Case:=Generate_Case(x,y,nb_possibility);
                begin
                    while Values_Already_tested(new_nb.nb) loop
                        new_nb:=Generate_Case(x,y,nb_possibility);
                    end loop;
                    Values_Already_tested(new_nb.nb):=True;
                    Value_test:=Value_test+1;
                    G(y)(x):=new_nb;
                end;
            end if;
        end loop;
        return true;
    end;


    procedure Put_Line(g : grid) 
    is
    begin
        for y in 1..9 loop
            for x in 1..9 loop
               if not g(y)(x).Visible then
                   put(" -");
                else
                    put(Integer'Image(g(y)(x).Nb));
                end if;
            end loop;
            new_line;
        end loop;
    end Put_Line;

    g : grid:=(others => (others=>(Nb=>1,Visible=>False)));
    b :  boolean;
begin
    Reset(Rand);
    Put_line("hello word"&Random(Rand)'Image);
    b:=Generate_Grid(g,1,1);
    put_line(b'Image);
    Put_line(g);
end main;


