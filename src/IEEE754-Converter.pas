program converter;
{
    Programa IEEE754-Converter Conversor de coma flotante de precision limitada.
    Autor: Oscar Blanco Novoa (O.blanco) <o.blanco@udc.es>
    Versión: 1.0 (Relase)
}

CONST
ieee2decStr = 'ieeetodec';
dec2ieeeStr = 'dectoieee';
spStr = 'sp';
dpStr = 'dp';

TYPE
	Nstring = string[255];
	ConversionType = (dec2ieee, ieee2dec);
	PrecisionType = (sp, dp);
	Tconfig = RECORD
		conversion:ConversionType;
		precision:PrecisionType;
	END;
	
VAR
    debug,detail:boolean;
	config:Tconfig;
	number:Nstring;

(* *********************************************** *)

PROCEDURE printHelp;
BEGIN
    writeln('Uso:');
    writeln('IEEE754-Converter (ieeetodec | dectoieee) (sp | dp) NUMERO [--DEBUG] [--DETAIL]');
    writeln('Convierte de coma flotante a decimal y viciversa.');
    writeln(' ');
    writeln('EJEMPLO: IEEE754-Converter ieeetodec sp 0x41240000 --DETAIL');
    writeln(' ');
END;

(* *********************************************** *)
		
FUNCTION checkParams:boolean;
	{ Obtiene los parametros de entrada del programa, comprueba 
	que son correctos y los guarda en el registro config }
VAR
	error:boolean;
BEGIN
    IF debug THEN writeln('Function: checkParams. parametros = ', paramstr(1), ' ', paramstr(2), ' ', paramstr(3), ' ', paramstr(4), ' ', paramstr(5));
	error := FALSE;
	
	IF ((paramstr(1) = '--help') OR (paramstr(1) = '')) THEN BEGIN
	    printHelp;
	    halt;
	END;
	
	IF ((paramstr(4) = '--DEBUG') OR (paramstr(5) = '--DEBUG')) THEN
	    debug := TRUE
	ELSE
	    debug := FALSE;
	
	IF ((paramstr(4) = '--DETAIL') OR (paramstr(5) = '--DETAIL')) THEN
	    detail := TRUE
	ELSE
	    detail := FALSE;
	
	IF paramstr(1) = ieee2decStr THEN
		config.conversion := ieee2dec
	ELSE IF paramstr(1) = dec2ieeeStr THEN
		config.conversion := dec2ieee
	ELSE
		error := TRUE;
	
	IF paramstr(2) = spStr THEN
		config.precision := sp
	ELSE IF paramstr(2) = dpStr THEN
		config.precision := dp
	ELSE
		error := TRUE;
		
	IF NOT error THEN
		BEGIN
		number := paramstr(3);
		checkParams := TRUE;
		END
	ELSE
		checkParams := FALSE;
END;

(* *********************************************** *)

FUNCTION isDec(VAR number:Nstring):boolean;
	{ Comprueba si el valor pasado es un decimal correcto }
VAR
	i:integer;
	error, point:boolean;
BEGIN
	IF debug THEN writeln('Function: isDec. number = ', number);
	error := FALSE; point := FALSE; i:= 1;
	
	WHILE (NOT error) AND (i <= length(number)) DO BEGIN
		CASE number[i] OF
			'0'..'9': ;
			'-', '+': IF i <> 1 THEN error := TRUE; { Signo en una posicion incorrecta }
			',': BEGIN number[i] := '.'; IF ((point) OR (i = 1) OR ((i = 2) and (number[1] IN ['-','+']))) THEN error := TRUE ELSE point := true; END; { Convertimos comas a puntos }
			'.': IF ((point) OR (i = 1) OR ((i = 2) and (number[1] IN ['-','+']))) THEN error := TRUE ELSE point := true; { Controlamos que no haya mas de 1 punto y que haya al menos 1 cifra antes de el }
			ELSE
				error := TRUE;
		END;
			i := i + 1;
	END;
	
	IF NOT error THEN
		isDec := TRUE
	ELSE
		isDec := FALSE;
END;

(* *********************************************** *)

FUNCTION isHex(VAR number:Nstring):boolean;
	{ Comprueba si el valor pasado es un exadecimal correcto sin x0
	  y lo convierte todo a minusculas de manera permanente por referencia }
VAR
	error:boolean;
	i:integer;
BEGIN
	IF debug THEN writeln('Function: isHex. number = ', number);
	error := FALSE; i:= 1;
	
	WHILE (NOT error) AND (i <= length(number)) DO BEGIN
		IF number[i] IN ['A'..'Z'] THEN
			number[i] := chr(ord(number[i])-(ord('A')-ord('a'))); { Convertimos a minuscula }
		IF ((number[i] IN ['a'..'f']) AND (number[i] IN ['1'..'9'])) THEN
			error := TRUE;
		i := i + 1;
	END;
	IF NOT error THEN
		isHEX := TRUE
	ELSE
		isHEX := FALSE;
END;

(* *********************************************** *)

FUNCTION binaryToHex (number:Nstring):Nstring;
VAR
	auxStr, aux:Nstring;
BEGIN
    IF debug THEN writeln('Function: binaryToHex. number = ', number);
    
	auxStr := '0x';
	WHILE length(number) > 1 DO BEGIN
		aux := copy(number, 1, 4); { seleccionamos el primer octeto }
		delete(number, 1, 4);
		IF aux = '0000' THEN auxStr := auxStr + '0'
		ELSE IF aux = '0000' THEN auxStr := auxStr + '0'
		ELSE IF aux = '0001' THEN auxStr := auxStr + '1'
		ELSE IF aux = '0010' THEN auxStr := auxStr + '2'
		ELSE IF aux = '0011' THEN auxStr := auxStr + '3'
		ELSE IF aux = '0100' THEN auxStr := auxStr + '4'
		ELSE IF aux = '0101' THEN auxStr := auxStr + '5'
		ELSE IF aux = '0110' THEN auxStr := auxStr + '6'
		ELSE IF aux = '0111' THEN auxStr := auxStr + '7'
		ELSE IF aux = '1000' THEN auxStr := auxStr + '8'
		ELSE IF aux = '1001' THEN auxStr := auxStr + '9'
		ELSE IF aux = '1010' THEN auxStr := auxStr + 'a'
		ELSE IF aux = '1011' THEN auxStr := auxStr + 'b'
		ELSE IF aux = '1100' THEN auxStr := auxStr + 'c'
		ELSE IF aux = '1101' THEN auxStr := auxStr + 'd'
		ELSE IF aux = '1110' THEN auxStr := auxStr + 'e'
		ELSE IF aux = '1111' THEN auxStr := auxStr + 'f';
	END;
	binaryToHex := auxStr;
END;

(* *********************************************** *)

FUNCTION decToBinary (number:Nstring):Nstring;
VAR
	decimal,pentera:extended;
	binary,aux:Nstring;
	i:integer;
BEGIN
    IF debug THEN writeln('Function: decToBinary. number = ', number);
    
	decimal := 0;
	val(number, decimal);
	
	IF decimal < 0 THEN
		binary := '-'
	ELSE
		binary := '+';
	
	aux := '';
	pentera := decimal - frac(decimal);
	decimal := frac(decimal);
	
	WHILE pentera <> 0 DO BEGIN
		IF frac(pentera / 2) <> 0 THEN
			aux := aux + '1'
		ELSE
			aux := aux + '0';
		pentera := pentera / 2;
		pentera := pentera - frac(pentera); 
	END;
	
	IF aux = '' THEN
		aux := '0';
	
	FOR i := length(aux) DOWNTO 1 DO
		binary := binary + aux[i];
	
	IF decimal <> 0 THEN
		binary := binary + '.';
	i := 1;
	while ((frac(decimal) <> 0) AND (length(binary) < 254)) DO BEGIN
		decimal := decimal * 2;
		IF (((decimal - frac(decimal)) >= 1) OR ((decimal - frac(decimal)) <= -1)) THEN BEGIN
			binary := binary + '1';
			decimal := frac(decimal);	
			END
		ELSE
			binary := binary + '0';
		i := i + 1;
	END;
	
	decToBinary := binary;
END;

(* *********************************************** *)

FUNCTION BinaryToDec (number:Nstring; exponente:real; exp_:boolean):real;
VAR
i:integer;
n:real;
BEGIN
    IF debug THEN writeln('Function: BinaryToDec. number = ', number);
    
	n := 0;
	IF exp_ THEN
		exponente :=length(number)-1;
	FOR i := 1 TO length(number) DO BEGIN
		if number[i] = '1' THEN
			n := n + exp(exponente*ln(2)); { n + 2 ^ exponente }
		exponente := exponente - 1;
	END;
	BinaryToDec := n;
END;

(* *********************************************** *)

FUNCTION hexToBinary (number:Nstring):Nstring;
VAR
auxStr:Nstring;
i:integer;
BEGIN
    IF debug THEN writeln('Function: hexToBinary. number = ', number);
    
	auxStr := '';
	FOR i := 1 TO length(number) DO
		CASE number[i] OF
		    '0': auxStr := auxStr + '0000';
			'1': auxStr := auxStr + '0001';
			'2': auxStr := auxStr + '0010';
			'3': auxStr := auxStr + '0011';
			'4': auxStr := auxStr + '0100';
			'5': auxStr := auxStr + '0101';
			'6': auxStr := auxStr + '0110';
			'7': auxStr := auxStr + '0111';
			'8': auxStr := auxStr + '1000';
			'9': auxStr := auxStr + '1001';
			'a': auxStr := auxStr + '1010';
			'b': auxStr := auxStr + '1011';
			'c': auxStr := auxStr + '1100';
			'd': auxStr := auxStr + '1101';
			'e': auxStr := auxStr + '1110';
			'f': auxStr := auxStr + '1111';
		END;
	hexToBinary := auxStr;
END;

(* *********************************************** *)

FUNCTION handleIeee2decExceptions(exponente:Nstring; mantisa:Nstring; expN:integer; mantN:integer):boolean;
VAR
exp0,exp1,mant0:Nstring;
BEGIN
    exp0 := ''; exp1 := ''; mant0 := '';
    WHILE length(exp0) < expN DO
        exp0 := exp0 + '0';
    
    WHILE length(exp1) < expN DO
        exp1 := exp1 + '1';
    
    WHILE length(mant0) < mantN DO
        mant0 := mant0 + '0';
    
    handleIeee2decExceptions := TRUE;
    IF ((exponente = '') AND (mantisa = '1')) THEN
        writeln('0')
    ELSE IF ((exponente = exp1) AND (mantisa = '1000')) THEN
        writeln('INF')
    ELSE IF ((exponente = exp1) AND (mantisa <> '1')) THEN
        writeln('NaN')
    ELSE
        handleIeee2decExceptions := FALSE;	
END;

(* *********************************************** *)

FUNCTION Convert(conversion:ConversionType; precision:PrecisionType; number:Nstring):Nstring;
VAR
expN,mantN,long,exceso,exponent:integer;
signo:string[1];
exponente:string[11];
mantisa:string[52];
inf,nan,cero:string[30];
s:real;
result:Nstring;
BEGIN
	IF debug THEN writeln('Function: Convert, conversion = ', conversion, ' precision = ', precision, ' number = ', number);
	
	IF precision = sp THEN BEGIN
		expN := 8;
		mantN := 23;
		long := 8;
		exceso := 127;
		inf := '0x7f800000 (InF)';
		nan := '0xffffffff (NaN)';
		cero := '0x00000000';
	END
	ELSE BEGIN
		expN := 11;
		mantN := 52;
		long := 16;
		exceso := 1023;
		inf := '0x7ff0000000000000 (InF)';
		nan := '0xffffffffffffffff (NaN)';
		cero := '0x0000000000000000';
	END;
	
	IF conversion = ieee2dec THEN BEGIN
		number := copy(number, 3, length(number)-2); { Eliminamos el 0x del inicio }
		
		IF (length(number) = long) AND (isHex(number)) THEN BEGIN
			number := hexToBinary(number);
			signo := copy(number, 1, 1);
			exponente := copy(number, 2, expN);
			mantisa := '1' + copy(number, 2+ExpN, MantN);
			
			IF signo = '1' THEN
				s := -1
			ELSE
				s := 1;
			
			IF (handleIeee2decExceptions(exponente, mantisa, expN, mantN)) THEN
				exit;

			str(binaryToDec(mantisa, binaryToDec(exponente, 0, TRUE)-exceso, FALSE) * s, result);
			
			WHILE length(exponente) < expN DO { rellenamos por estilo }
			    exponente := exponente + '0';
			WHILE length(mantisa) < mantN DO
			    mantisa := mantisa + '0';
			
			IF detail THEN writeln(signo, '  |  ', exponente, '  |  ', copy(mantisa, 2, length(mantisa)-1));
			
			Convert := result;
			END
		ELSE
			Convert := 'El numero hexadecimal insertado no tiene el formato correcto.';
	END
	ELSE BEGIN
		IF isDec(number) THEN BEGIN
			number := decToBinary(number);
			IF pos('1', number) = 0 THEN
				exit(cero); (* excepccion de 0 *)
			
			IF pos('.', number) <> 0 THEN
				exponent := pos('.', number)-3
			ELSE 
				exponent := length(number)-2; { corremos la coma a la izquierda 1,1111.11}
			
			IF ((exponent = 0) AND (number[2] = '0')) THEN
				exponent := (pos('1', number)-3) * -1; { corremos la coma a la derecha 0.000001,}
			
			exponent := exponent+exceso;
			IF exponent > exceso*2 THEN
				exit(inf); (* Excepccion de infinito *)
				
			IF exponent >= 0 THEN
				mantisa := copy(number, pos('1', number)+1, mantN+1)
			ELSE BEGIN
			    (* Dejamos ceros en la mantisa puesto que en el exponente no caben (desnormalizado) *)
			    writeln('Estado: desnormalizado.');
				mantisa := copy(number, pos('1', number)-exponent*-1, mantN+1); 
				exponent := 0;
			END;
			
			delete(mantisa, pos('.',mantisa),1); 
			WHILE length(mantisa) < mantN DO (* rellenamos huecos *)
				mantisa := mantisa + '0';

			str(exponent, exponente);
			exponente := copy(decToBinary(exponente), 2, expN); (* copiamos exponente sin el signo *)
			WHILE length(exponente) < expN DO (* rellenamos huecos *)
				exponente := '0' + exponente;
			
			IF number[1] = '-' THEN
				signo := '1'
			ELSE
				signo := '0';
			
			IF detail THEN writeln(signo, '  |  ', exponente, '  |  ', mantisa);
			
			result := signo + exponente + mantisa;
			Convert := binaryToHex(result);	
		END
		ELSE
			Convert := nan; (* excepccion NaN *)
	END;

END;
	
BEGIN
	IF checkParams THEN
		writeln(convert(config.conversion, config.precision, number))
	ELSE
	    BEGIN
		writeln('Los parametros insertados no son validos.');
		writeln('Escribe --help  para mostrar la ayuda del programa.');
		END;
END.
