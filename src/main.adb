With Ada.Text_IO;           use Ada.Text_IO;
With Ada.Numerics.Discrete_Random;

procedure main is 
    -- number that can be put in a suboku Cell
    subtype Number is Natural range 1..9;
    package Discrete_Random is new Ada.Numerics.Discrete_Random(number);
    use Discrete_Random;
    Rand : Generator;
    -- type of a Cell in the sudoku grid
    type T_Cell is record
        Nb : Number;
        Visible : Boolean;
    end record;
    -- theses array are index by Number so they are indexed from 1 to 9
    type Line is array (Number) of T_Cell;
    type Grid is array (Number) of Line;
    type Possible_Nb is array(Number) of Boolean;

    -- Display a Sudoku grid in the console
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

    -- Display an Array of boolean, useful for debugging
    procedure Put_line(p : Possible_Nb) 
    is
    begin
        for e of p loop
            put(e'Image);
            put(";");
        end loop;
        new_line;
    end Put_line;


    -- This Function return an boolean array of the possible numbers of a sudoku Cell and the number of differents values possibility for this Cell
    -- It use only visible Cell on the grid
    -- It need the grid, the Cell coordonates, the top left Cell coordonates of the square
    -- Number of possibility musb be a  Natural because it can be 0
    function Find_Possible_Nb(G : Grid; x :  Number; y : Number; X_square : Number; Y_square : Number; nb_possibility : out Natural) return Possible_Nb
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
                if G(Y_square+i)(X_square+k).Visible then
                    Possible_Numbers(G(Y_square+i)(X_square+k).Nb):=False;
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


    -- This function generates a Valide Sudoku grid with all the Cells visible
    -- This function returns True or False whether the generation is successful or not
    -- It's a backtracting algorithm
    -- The Input grid must be empty, default value (Nb=1,Visible=>False)
    function Generate_Grid(G : in out grid; x : Number:=1; y : Number:=1) return Boolean
    is

        -- this function returns a sudoku Cell that wasn't test before
        -- this function needs the Possible numbers of this Cell and the Values already tested
        function Get_Cell_In_Possibility(Possible_Numbers : Possible_Nb; Values_Already_tested : in out Possible_Nb) return T_Cell
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
        end Get_Cell_In_Possibility;

        X_square : Number:=((x-1)/3)*3+1;
        Y_square : Number:=((y-1)/3)*3+1; 
        next_X : Number;
        next_y : Number;
        nb_possibility : Natural;
        Value_test :  Natural:=0;
        Possible_Numbers : Possible_Nb:=(others=>False);
        Values_Already_tested : Possible_Nb:=(others => False);

    begin
        Possible_Numbers:=Find_Possible_Nb(g,x,y,X_square,Y_square,nb_possibility);
        if nb_possibility=0 then
            return false; -- no posibilities we go back
        end if;
        G(y)(x):=Get_Cell_In_Possibility(Possible_Numbers,Values_Already_tested);
        Value_test:=Value_test+1;

        if x=9 and y=9 then
            return true; -- Last Cell complete
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
                G(y)(x):=(1,False); -- set the actual Cell with default value
                return false; -- if all the possiblities are tested and we still can't go further we go back 
            else
                G(y)(x):=Get_Cell_In_Possibility(Possible_Numbers,Values_Already_tested);
                Value_test:=Value_test+1;
            end if;
        end loop;
        return true; -- if everything goes well
    end Generate_Grid;

    -- this function transform the Input Grid (the Solution) into a Playable grid with a unique Solution
    function Playable_Grid(g :grid) return grid 
    is
        -- this function hide a random Cell
        procedure Hide_Cell(g : in out grid) is
            x : Number:=Random(Rand);
            y : Number:=Random(Rand);
        begin
            while not g(y)(x).Visible loop
                x:=Random(Rand);
                y:=Random(Rand);
            end loop;
            g(y)(x).Visible:=False;
        end Hide_Cell;

        -- this function returns true if all the values of the grid are Visible
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
                    
        Playable_G : grid:=g; --grid that we will return
        tmp_G : grid:=Playable_G; -- same grid as Playable_G grid but with another Cell Hide
        Test_Temp_G : grid:=Playable_G; -- same grid as tmp_G that we will try to solve
        Changed : boolean;
        X_square : Number;
        Y_square : Number;
        Possible_Numbers : Possible_Nb;
        Nb_Of_Possibility : Natural;
        Nb_Hiding_Cells : Natural:=0;
    begin
        while Is_Complete(Test_Temp_G) loop -- if we still manage to complete the grid we try to hide another Cell
           Playable_G:=tmp_G;  
           Hide_Cell(tmp_G);
           Nb_Hiding_Cells:=Nb_Hiding_Cells+1;
           Test_Temp_G:=tmp_G;
           Changed:=True;
           while Changed loop -- if we have found a Cell that can be played we search for another Cell that can be played
               Changed:=False;
               for y in 1..9 loop
                   for x in 1..9 loop
                       if not Test_Temp_G(y)(x).Visible then
                           X_square :=((x-1)/3)*3+1;
                           Y_square :=((y-1)/3)*3+1; 
                           Possible_Numbers:=Find_Possible_Nb(Test_Temp_G,x,y,X_square,Y_square,Nb_Of_Possibility);
                           if Nb_Of_Possibility=1 then
                               Test_Temp_G(y)(x).Visible:=True;
                               Changed:=True;
                            end if;
                        end if;
                    end loop;
                end loop;
            end loop;
        end loop;
        put_line("Number of Hiding Cells :"&Nb_Hiding_Cells'Image);
        put_line("Number of Visible Cells :"&Integer'Image(91-Nb_Hiding_Cells));
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


