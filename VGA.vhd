library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (2 downto 0);
			  VGA_CLK: out STD_LOGIC;
			  lButton,rButton,uButton: in std_LOGIC;
			  a_life, b_life,c_life, d_life,e_life,f_life,g_life: out std_logic;
			  d1 : out std_LOGIC_VECTOR (6 downto 0);
			  d2 : out std_LOGIC_VECTOR (6 downto 0)
			  );
end entity;

architecture Behavioral of VGA is

	type state_type is (s0,s1,s2);
	
	signal stage: state_type:=s1;

	signal clk25 : std_logic := '0';
	
	constant HD : integer := 639;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant HSP : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	signal pvPos: integer  := VD;
	signal pT: integer :=VD-10;
	signal pB: integer :=VD;
	signal pL: integer :=10;
	signal pR: integer :=20;

	signal eT: integer :=VD-15;
	signal eB: integer :=VD-5;
	signal eL: integer :=385;
	signal eR: integer :=405;
	
	signal eT1: integer :=385;
	signal eB1: integer :=395;
	signal eL1: integer :=385;
	signal eR1: integer :=405;
	
	signal eT2: integer :=305;
	signal eB2: integer :=315;
	signal eL2: integer :=385;
	signal eR2: integer :=405;
	
	signal eT3: integer :=205;
	signal eB3: integer :=215;
	signal eL3: integer :=385;
	signal eR3: integer :=405;
	
	signal CLK_1Hz: std_logic:='0';
	signal counter: std_LOGIC_VECTOR(28 downto 0);
	signal jCounter: std_logic_vector(28 downto 0);
	signal invulnerable: std_logic_vector(32 downto 0);
	signal jump: std_logic;
	signal videoOn : std_logic := '0';
	signal onPlatform: std_logic := '0';
	signal platRBound: integer:= 0;
	signal platLBound: integer:= 0;
	signal platTop: integer :=0;
	signal water : std_logic := '0';
	--signal enemyCounter: std_LOGIC_VECTOR(28 downto 0);
	signal loseLife: std_logic:= '0';
	
	signal lives : integer := 1;
	
	signal count : std_logic_vector(3 downto 0);
	
	signal coin1 : std_logic:= '1';
	signal coin2 : std_logic:= '1';
	signal coin3 : std_logic:= '1';
	signal coin4 : std_logic:= '1';
	signal coin5 : std_logic:= '1';	
	signal coin7 : std_logic:= '1';
	signal coin8 : std_logic:= '1';
	signal coin9 : std_logic:= '1';
	signal coin10 : std_logic:= '1';
	signal secondstg: std_LOGIC:='1';
	signal coins2_1 : std_logic:= '1';
	signal coins2_2 : std_logic:= '1';
	signal coins2_3 : std_logic:= '1';
	signal coins2_6 : std_logic:= '1';
	signal coins2_7 : std_logic:= '1';
	signal coins2_9 : std_logic:= '1';
   signal coins2_4 : std_logic:= '1';
	
	component Score
		port(
		count: in std_logic_vector(3 downto 0);
		rst : in std_logic;
		d1 : out std_logic_vector(6 downto 0);
		d2 : out std_logic_vector(6 downto 0)
		);
	end component;
	
	impure function circle(rx, ry, x, y, r : integer) return std_logic is -- Nick Wayne Function code
	begin	
		if (rx - x)**2 + (ry - y)**2 < r*r then
			return '1';
		else
			return '0';
		end if;
	end circle;

begin


clk_div:process(CLK)
begin
	if(CLK'event and CLK = '1')then
		clk25 <= not clk25;
	end if;
end process;
VGA_CLK <= clk25;
Prescaler: process (CLK)
begin  -- process Prescaler
	if CLK'event and CLK = '1' then  -- rising clock edge
		if counter < "101111101011110000100" then
			counter <= counter + 1;
		else
			CLK_1Hz <= not CLK_1Hz;
			counter <= (others => '0');
		end if;
	end if;
end process Prescaler;

Horizontal_position_counter:process(clk25, RST)
begin
	if(RST = '1')then
		hpos <= 0;
	elsif(clk25'event and clk25 = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(clk25, RST, hPos)
begin
	if(RST = '1')then
		vPos <= 0;
	elsif(clk25'event and clk25 = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(clk25, RST, hPos)
begin
	if(RST = '1')then
		HSYNC <= '0';
	elsif(clk25'event and clk25 = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(clk25, RST, vPos)
begin
	if(RST = '1')then
		VSYNC <= '0';
	elsif(clk25'event and clk25 = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end if;
end process;

video_on:process(clk25, RST, hPos, vPos)
begin
	if(RST = '1')then
		videoOn <= '0';
	elsif(clk25'event and clk25 = '1')then
		if(hPos <= HD and vPos <= VD)then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;
	end if;
end process;



moveBlock:process(CLK_1Hz, RST, videoOn, coin1, coin2,coin3,coin4,coin5,coin7,coin8,coin9,coin10)
begin
	if(RST = '1') then
		pL <= 10;
		pR <= 20;
		
		
	elsif rising_edge(CLK_1Hz) then
			if pR > 417 and pT >190 and stage = s1 then
				water <= '1';
			else 
				water <= '0';
			end if;

			if(pL >= 0 and pR <= HD) then
				
					if(rButton = '0' and ((pR < 405 or pR > 417) or pB < 190))then
						pL <= pL + 5;
						pR <= pR + 5;
						
					elsif (lButton = '0' and (pL < 416 or pL > 419) ) then
						pL <= pL - 5;
						pR <= pR - 5;
					end if;
	
			else 
				pL <= 10;
				pR <= 20;
			end if;
		
		end if;
	    

end process;

lifeCounter: process (CLK,RST,stage)
begin

	if stage = s0 then
		a_life <= '0';
		b_life <= '0';
		c_life <= '0';
		d_life <= '0';
		e_life <= '0';
		f_life <= '0';
		g_life <= '1';
	else
		a_life <= '1';
		b_life <= '0';
		c_life <= '0';
		d_life <= '1';
		e_life <= '1';
		f_life <= '1';
		g_life <= '1';
	end if;
		
----	if lives = 3 then
----		a_life <= '0';
----		b_life <= '0';
----		c_life <= '0';
----		d_life <= '0';
----		e_life <= '1';
----		f_life <= '1';
----		g_life <= '0';
----	elsif lives = 2 then
----		a_life <= '0';
----		b_life <= '0';
----		c_life <= '1';
----		d_life <= '0';
----		e_life <= '0';
----		f_life <= '1';
----		g_life <= '0';
--	if lives = 1 then
--		a_life <= '1';
--		b_life <= '0';
--		c_life <= '0';
--		d_life <= '1';
--		e_life <= '1';
--		f_life <= '1';
--		g_life <= '1';
--	else
--		a_life <= '0';
--		b_life <= '0';
--		c_life <= '0';
--		d_life <= '0';
--		e_life <= '0';
--		f_life <= '0';
--		g_life <= '1';
--		
--	end if;
end process;

bullets: process (CLK_1Hz,RST, videoOn,eL,eR)
begin
	if(RST = '1') then
		eL<= 385;
		eR<=405;
		eL1<=385;
		eR1<=405;
		eL2<=385;
		eR2<=405;
		eL3<=385;
		eR3<=405;
	elsif rising_edge(CLK_1Hz) then
		if(eR>0) then
			eL<=eL-5;
			eR<= eR-5;
			eL1<=eL1-7;
			eR1<= eR1-7;
			eL2<=eL2-7;
			eR2<= eR2-7;
			eL3<=eL3-5;
			eR3<= eR3-5;
		else
			eL<= 385;
			eR<=405;
			eL1<=385;
			eR1<=405;
			eL2<=385;
			eR2<=405;
			eL3<=385;
			eR3<=405;
		
	end if;
end if;
end process;

jumpBlock:process(CLK_1Hz, RST, videoOn, platTop, stage)
begin
	if rising_edge(CLK_1Hz) then
		if(RST ='1') then
			pT <= VD-10;
			pB <=VD;
		elsif(jump = '1')then
				if(jCounter < "1100") then	
					pT<= pT -5;
					pB<= pB - 5;
					jCounter <= jCounter +1;
					if(onPlatform = '1') then
						pvPos<= platTop;
					else
						pvPos <= VD;
					end if;
				elsif(pB < pvPos)then
					if(onPlatform = '0') then
						pvPos <=VD;
					elsif(stage = s0) then
						pvPos <= VD+20;
					else 
						pvPos <= platTop;
					end if;
					if(water = '1' and stage = s1) then
					pT <= pT + 2;
					pB <= pB +2;
					else
					pT <= pT+5;
					pB<= pB +5;
					end if;
				else
					jCounter<= (others => '0');
					jump<= '0';
					pvPos <= VD;
				end if;
		--(pL>platRBound or pR < PlatLBound)and
		elsif(uButton = '0')then
			jump <='1';
		elsif(onPlatform = '0') then
				if( pB < VD) then
					pT <= pT+5;
					pB<= pB +5;
				end if;
		elsif(onPlatform = '1') then
				if(pB < platTop)then
					pT <= pT+5;
					pB<= pB +5;
				end if;
		end if;
			
	end if;
end process;


drawPlayer1:process(clk25, RST, hPos, vPos, videoOn)
begin

	if(RST = '1')then
		RGB <= "000";
		stage <= s1;
	elsif(clk25'event and clk25 = '1')then
		if(videoOn = '1')then
			case stage is
				when s1=>
					-----------------------------------------------------------------------------------------------Platforms
					if((hPos >= pL and hPos <= pR) AND (vPos >= pT and vPos <= pB))then
						RGB <= "100";
					elsif((hPos >= 50 and hPos <= 90) AND (vPos >= 440 and vPos <= 443)) then --plat1
						RGB <= "010";
					elsif((hPos >= 120 and hPos <= 160) AND (vPos >= 430 and vPos <= 433)) then --- plat 2: done making solid
						RGB <= "010";
					elsif((hPos >= 200 and hPos <= 240) AND (vPos >= 415 and vPos <= 418)) then -- plat 3:done drawing
						RGB <= "010";
					elsif((hPos >= 280 and hPos <= 320) AND (vPos >= 430 and vPos <= 433)) then --plat 4: done drawing
						RGB <= "010";
					elsif((hPos >= 280 and hPos <= 320) AND (vPos >= 380 and vPos <= 383)) then --plat 5: done drawing
						RGB <= "010";
					elsif((hPos >= 365 and hPos <= 405) AND (vPos >= 415 and vPos <= 418)) then --plat 6: done drawing
						RGB <= "010";
					elsif((hPos >= 180 and hPos <= 240) AND (vPos >= 360 and vPos <= 363)) then --plat 7: done drawing
						RGB <= "001";
					elsif((hPos >= 250 and hPos <= 290) AND (vPos >= 330 and vPos <= 333)) then --plat 8: done drawing
						RGB <= "010";
					elsif((hPos >= 50 and hPos <= 90) AND (vPos >= 320 and vPos <= 323)) then --plat 9: done drawing
						RGB <= "010";
					elsif((hPos >= 310 and hPos <= 350) AND (vPos >= 300 and vPos <= 303)) then --plat 10: done drawing
						RGB <= "010";
					elsif((hPos >= 100 and hPos <= 170) AND (vPos >= 255 and vPos <= 258)) then --plat 11: done drawing
						RGB <= "010";
					elsif((hPos >= 225 and hPos <= 270) AND (vPos >= 270 and vPos <= 273)) then --plat 12: done drawing
						RGB <= "001";
					elsif((hPos >= 200 and hPos <= 260) AND (vPos >= 225 and vPos <= 228)) then --plat 13: done drawing
						RGB <= "001";
					elsif((hPos >= 300 and hPos <= 375) AND (vPos >= 185 and vPos <= 188)) then --plat 14: done drawing
						RGB <= "010";
					-------------------------------------------------------------------------------------------------------platforms end
					elsif((circle(hPos, vPos, 490, 200, 5) = '1')) then	----- coin 7 in water
						if((coin7 = '1') ) then
							RGB <= "110";
						elsif((coin7 = '0')) then
						RGB <= "011"; 					
						end if;					
					elsif((circle(hPos, vPos, 510, 250, 5) = '1')) then	----- coin 8 in water
						if((coin8 = '1') ) then
							RGB <= "110";
						elsif((coin8 = '0')) then
						RGB <= "011"; 						
						end if;					
					elsif((circle(hPos, vPos, 425, 465, 5) = '1')) then	----- coin 9 in water
						if((coin9 = '1') ) then
							RGB <= "110";
						elsif((coin9 = '0')) then
						RGB <= "011"; 					
						end if;
						--------------------------------------------------------------------------------------------------- Miscellaneous Objects
					elsif((hPos >= 407 and hPos <= 417) AND (vPos >=170  and vPos <= VD)) then --Wall: done drawing
						RGB <= "101";
					elsif((hPos >= 419 and hPos <= 449) AND (vPos >= 190 and vPos <=VD)) then --water1: done drawing
						RGB <= "011";
					elsif((hPos >= 481 and hPos <= HD) AND (vPos >= 190 and vPos <= VD)) then --water2:
						RGB <= "011";
					elsif((hPos >= 449 and hPos <= 481) AND (vPos >= 190 and vPos <= VD-40)) then --plat 10:
						RGB <= "011";
					elsif((hPos >= 450 and hPos <= 480) AND (vPos >= VD-40 and vPos <= VD)) then --Door to stage 2: done drawing
						RGB <= "110";
					elsif((hPos >=396 and hPos <= 406) AND (vPos >= VD-20 and vPos <= VD)) then --canon
						RGB <= "000";
					elsif((hPos >=396 and hPos <= 406) AND (vPos >= 380 and vPos <= 400)) then --canon2
						RGB <= "000";
					elsif((hPos >=396 and hPos <= 406) AND (vPos >= 300 and vPos <= 320)) then --canon3
						RGB <= "000";
					elsif((hPos >=396 and hPos <= 406) AND (vPos >= 200 and vPos <= 220)) then --canon4
						RGB <= "000";
					elsif((hPos >=eL and hPos <= eR) AND (vPos >=  eT and vPos <= eB)) then --enemy1
						RGB <= "000";
					elsif((hPos >=eL1 and hPos <= eR1) AND (vPos >=  eT1 and vPos <= eB1)) then --enemy2
						RGB <= "000";
					elsif((hPos >=eL2 and hPos <= eR2) AND (vPos >=  eT2 and vPos <= eB2)) then --enemy3
						RGB <= "000";
					elsif((hPos >=eL3 and hPos <= eR3) AND (vPos >=  eT3 and vPos <= eB3)) then --enemy4
						RGB <= "000";					
				
--------------------------------------------------------------------------------------------- coins					
					elsif((circle(hPos, vPos, 65, 465, 5) = '1')) then	----- coin 1
						if((coin1 = '1') ) then
							RGB <= "110";
						elsif((coin1 = '0')) then
							RGB <= "111"; 
						end if;
					elsif((circle(hPos, vPos, 65, 430, 5) = '1')) then	----- coin 10
						if((coin10 = '1') ) then
							RGB <= "110";
						elsif((coin10 = '0')) then
						RGB <= "111"; 						
						end if;						
					elsif((circle(hPos, vPos, 255, 175, 5) = '1')) then	----- coin 2
						if((coin2 = '1') ) then
							RGB <= "110";
						elsif(coin2 = '0') then
						RGB <= "111"; 
						end if;						
					elsif((circle(hPos, vPos, 120, 465, 5) = '1')) then	----- coin 3
						if((coin3 = '1') ) then
							RGB <= "110";
						elsif((coin3 = '0')) then
						RGB <= "111"; 						
						end if;						
					elsif((circle(hPos, vPos, 215, 465, 5) = '1')) then	----- coin 4
						if((coin4 = '1')  ) then
							RGB <= "110";
						elsif((coin4 = '0')) then
						RGB <= "111";
						end if;						
					elsif((circle(hPos, vPos, 300, 465, 5) = '1')) then	----- coin 5
						if((coin5 = '1') ) then
							RGB <= "110";
						elsif((coin5 = '0') ) then
						RGB <= "111"; 
						end if;											
					else
						RGB <= "111";
					end if;
					if (pB > VD-40 and (pL > 450 and pR < 480)) then
						stage <= s2;
					elsif(pR > eL and pR<= eR+9) and ((pB < VD+3) and pB > eT) then
						stage <= s0;
					elsif(pR > eL1 and pR<= eR1+9) and ((pB < eB1+9) and pB > eT1) then
						stage <= s0;
					elsif(pR > eL2 and pR<= eR2+9) and ((pB < eB2+9) and pB > eT2) then
						stage <= s0;
					elsif(pR > eL3 and pR<= eR3+9) and ((pB < eB3+9) and pB > eT3) then
						stage <= s0;
					else
						stage <= s1;
					end if;
				when s0 =>
					if((hPos >= pL and hPos <= pR) AND (vPos >= pT and vPos <= pB))then
						RGB <= "100";
------------------------------------------------------------------------------------------------------ G
					elsif((hPos >= 200 and hPos <= 203) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 200 and hPos <= 223) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 200 and hPos <= 223) AND (vPos >= 227 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 220 and hPos <= 223) AND (vPos >= 215 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 212 and hPos <= 223) AND (vPos >= 215 and vPos <= 218))then
						RGB <= "111";
------------------------------------------------------------------------------------------------------A
					elsif((hPos >= 226 and hPos <= 229) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 226 and hPos <= 249) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 246 and hPos <= 249) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 226 and hPos <= 249) AND (vPos >= 215 and vPos <= 218))then
						RGB <= "111";
------------------------------------------------------------------------------------------------------M
					elsif((hPos >= 252 and hPos <= 255) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 252 and hPos <= 275) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 262 and hPos <= 265) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 272 and hPos <= 275) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
------------------------------------------------------------------------------------------------------E
					elsif((hPos >= 278 and hPos <= 281) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 278 and hPos <= 301) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 278 and hPos <= 301) AND (vPos >= 215 and vPos <= 218))then
						RGB <= "111";
					elsif((hPos >= 278 and hPos <= 301) AND (vPos >= 227 and vPos <= 230))then
						RGB <= "111";
------------------------------------------------------------------------------------------------------blocky
					elsif((hPos >= 307 and hPos <= 317) AND (vPos >= 210 and vPos <= 220)) then
						RGB <="100";
------------------------------------------------------------------------------------------------------O
					elsif((hPos >= 323 and hPos <= 326) AND (vPos >= 200 and vPos <= 230)) then
						RGB <="111";
					elsif((hPos >= 323 and hPos <= 346) AND (vPos >= 200 and vPos <= 203)) then
						RGB <="111";
					elsif((hPos >= 323 and hPos <= 346) AND (vPos >= 227 and vPos <= 230)) then
						RGB <="111";
					elsif((hPos >= 343 and hPos <= 346) AND (vPos >= 200 and vPos <= 230)) then
						RGB <="111";
------------------------------------------------------------------------------------------------------V
					elsif((hPos >= 349 and hPos <= 352) AND (vPos >= 200 and vPos <= 230)) then
						RGB <="111";
					elsif((hPos >= 349 and hPos <= 372) AND (vPos >= 227 and vPos <= 230)) then
						RGB <="111";
					elsif((hPos >= 369 and hPos <= 372) AND (vPos >= 200 and vPos <= 230)) then
						RGB <="111";
------------------------------------------------------------------------------------------------------E
					elsif((hPos >= 375 and hPos <= 378) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 375 and hPos <= 398) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 375 and hPos <= 398) AND (vPos >= 215 and vPos <= 218))then
						RGB <= "111";
					elsif((hPos >= 375 and hPos <= 398) AND (vPos >= 227 and vPos <= 230))then
						RGB <= "111";
------------------------------------------------------------------------------------------------------R
					elsif((hPos >= 401 and hPos <= 404) AND (vPos >= 200 and vPos <= 230))then
						RGB <= "111";
					elsif((hPos >= 401 and hPos <= 424) AND (vPos >= 200 and vPos <= 203))then
						RGB <= "111";
					elsif((hPos >= 421 and hPos <= 424) AND (vPos >= 200 and vPos <= 218))then
						RGB <= "111";
					elsif((hPos >= 401 and hPos <= 424) AND (vPos >= 215 and vPos <= 218))then
						RGB <= "111";
					elsif((hPos >= 419 and hPos <= 422) AND (vPos >= 215 and vPos <= 230))then
						RGB <= "111";
						
					else
						RGB <= "000";
					end if;
				when s2=>
					if((hPos >= pL and hPos <= pR) AND (vPos >= pT and vPos <= pB))then
						RGB <= "100";
						elsif((hPos >= 365 and hPos <= 405) AND (vPos >= 440 and vPos <= 443)) then --plat1:
						RGB <= "010";
					elsif((hPos >= 200 and hPos <= 280) AND (vPos >= 430 and vPos <= 433)) then --- plat 2: 
						RGB <= "010";
					elsif((hPos >= 50 and hPos <= 120) AND (vPos >= 415 and vPos <= 418)) then -- plat 3:
						RGB <= "010";
					--elsif((hPos >= 50 and hPos <= 90) AND (vPos >= 360 and vPos <= 363)) then --plat 4: not relevant  
						--RGB <= "010";
					elsif((hPos >= 120 and hPos <=200) AND (vPos >= 360 and vPos <= 363)) then --plat 5:  
						RGB <= "010";
					elsif((hPos >= 270 and hPos <= 340) AND (vPos >= 320 and vPos <= 323)) then --plat 6:  
						RGB <= "010";
					elsif((hPos >= 190 and hPos <= 230) AND (vPos >= 280 and vPos <= 283)) then --plat 7:  
						RGB <= "010";
					elsif((hPos >= 100 and hPos <= 160) AND (vPos >= 250 and vPos <= 253)) then --plat 8:  
						RGB <= "010";
					elsif((hPos >= 220 and hPos <= 270) AND (vPos >= 225 and vPos <= 228)) then --plat 9:  
						RGB <= "010";
					elsif((hPos >= 300 and hPos <= 365) AND (vPos >= 185 and vPos <=188)) then --plat 10:  
						RGB <= "010";
					elsif((hPos >= 440 and hPos <= 450) AND (vPos >=160  and vPos <= 163)) then --plat 1 over fire: 
						RGB <= "010";	
					elsif((hPos >= 520 and hPos <= HD) AND (vPos >= 150 and vPos <=153)) then --plat 2 over fire: 
						RGB <= "010";
					-------------------------------------------------------------------------------------------------------platforms end
					
					-------------------------------------------------------------------------------------------------------Misc Objects
					elsif((hPos >= 407 and hPos <= 417) AND (vPos >=170  and vPos <= 440)) then --Wall side: 
						RGB <= "000";
					elsif((hPos >= 407 and hPos <= HD) AND (vPos >=440  and vPos <= 450)) then --Wall bottom: 
						RGB <= "000";
						
					elsif((hPos >= 417 and hPos <= HD) AND (vPos >= 170 and vPos <=443)) then --fire: 
						RGB <= "100";
						
					------------------------------------------------------------------------------------------------------ Draw coins
					elsif(circle(hPos, vPos, 380, 435, 5) = '1') then --coin  plat 1
						if((coins2_1 = '1') ) then
							RGB <= "110";
					elsif((coins2_1 = '0') ) then
						RGB <= "111";							
						end if;
					elsif(circle(hPos, vPos, 240, 420, 5) = '1') then --coin  plat 4
						if((coins2_4 = '1') ) then
							RGB <= "110";
					elsif((coins2_4 = '0') ) then
						RGB <= "111"; 						
						end if;						
					elsif(circle(hPos, vPos, 60, 400, 5) = '1') then --coin  plat 2
						if((coins2_2 = '1') ) then
							RGB <= "110";
						elsif((coins2_2 = '0') ) then
						RGB <= "111"; 						
						end if;
					elsif(circle(hPos, vPos, 125, 345, 5) = '1') then --coin  above 3 
						if((coins2_3 = '1') ) then
							RGB <= "110";
						elsif((coins2_3 = '0') ) then
							RGB <= "111"; 
						end if;	
					elsif(circle(hPos, vPos, 240, 215, 5) = '1') then --coin  plat 7
						if((coins2_7 = '1') ) then
							RGB <= "110";
						elsif((coins2_7 = '0') ) then
							RGB <= "111"; 							
						end if;
					elsif(circle(hPos, vPos, 485, 125, 5) = '1') then --coin 9 plat over fire
						if((coins2_9 = '1') ) then
							RGB <= "110";
						elsif((coins2_9 = '0') ) then
							RGB <= "111"; 							
						end if;	
						
						
					else
						RGB <= "111";
					end if;
					
						
					----------
					if ((pB > 170 and pT < 443) and (pL > 417 and pR < HD)) then
						stage <= s0;
					else
						stage <= s2;
					end if;
					----------
				when others=>
					stage <= s1;
			end case;
		else
			RGB <= "000";
	end if;
end if;
end process;

blockPosition:process(CLK, RST,stage,pR,pL,pB,pT, platTop,loseLife, lives)
begin
	if(RST = '1') then
		lives <= 3;
		loseLife <= '0';
		coins2_1 <= '1';
		coins2_2 <= '1';
		coins2_3 <= '1';
		coins2_6 <= '1';
		coins2_7 <= '1';
		coins2_9 <= '1';
		coins2_4 <= '1';
		coin1 <= '1';
		coin2 <= '1';
		coin3 <= '1';
		coin4 <= '1';
		coin5 <= '1';		
		coin7 <= '1';		
		coin8 <= '1';
		coin9 <= '1';
		coin10 <='1';
		count <= (others => '0');
	elsif(stage = s1) then
			if ((pR > 51 and pL < 90) and (pB < 440 and pT > 410))then --plat1
					platRBound <= 90;
					platLBound <= 51;
					onPlatform <= '1';
					platTop<= 440-2;
			elsif((pR > 121 and pL < 160) and (pB < 430 and pT > 380)) then --plat 2
					platRBound <= 160;
					platLBound <= 121;
					onPlatform <= '1';
					platTop<= 430-2;
			elsif((pR > 201 and pL < 240) and (pB < 420 and pT > 400)) then --plat 3
					platRBound <= 239;
					platLBound <= 201;
					onPlatform <= '1';
					platTop<= 415-4;
			elsif((pR > 281 and pL < 320) and (pB < 430 and pT > 383)) then --plat4
					platRBound <= 320;
					platLBound <= 28;
					onPlatform <= '1';
					platTop<= 430-2;
			elsif((pR > 280 and pL < 320) and (pB < 380 and pT > 300)) then --plat5
					platRBound <= 320;
					platLBound <= 280;
					onPlatform <= '1';
					platTop<= 380-2;
--			elsif((pR > 365 and pL < 405) and (pB < 415 and pT > 365)) then --plat6: done
--					platRBound <= 405;
--					platLBound <= 365;
--					onPlatform <= '1';
--					platTop<= 415-2;
			elsif((pR > 180 and pL < 240) and (pB < 360 and pT > 340)) then --plat7
					platRBound <= 240;
					platLBound <= 180;
					onPlatform <= '1';
					platTop<= 360;
			elsif((pR > 250 and pL < 290) and (pB < 335 and pT > 315)) then --plat8
					platRBound <=290;
					platLBound <= 250;
					onPlatform <= '1';
					platTop<= 330-2;
--			elsif((pR > 50 and pL < 90) and (pB < 320 and pT > 305)) then --plat9
--					platRBound <= 90;
--					platLBound <= 50;
--					onPlatform <= '1';
--					platTop<= 320-2;
			elsif((pR > 310 and pL < 350) and (pB < 300 and pT > 245)) then --plat10
					platRBound <= 350;
					platLBound <= 310;
					onPlatform <= '1';
					platTop<= 300-2;
--			elsif((pR > 100 and pL < 170) and (pB < 255 and pT > 240)) then --plat11
--					platRBound <= 170;
--					platLBound <= 100;
--					onPlatform <= '1';
--					platTop<= 255-2;
			elsif((pR > 225 and pL < 270) and (pB < 270 and pT > 255)) then --plat12
					platRBound <= 270;
					platLBound <= 225;
					onPlatform <= '1';
					platTop<= 270-2;
			elsif((pR > 200 and pL < 260) and (pB < 227 and pT > 210)) then --plat13
					platRBound <= 260;
					platLBound <= 199;
					onPlatform <= '1';
					platTop<= 225-4;
			elsif((pR > 300 and pL < 375) and (pB < 185 and pT > 160)) then --plat14
					platRBound <= 375;
					platLBound <= 299;
					onPlatform <= '1';
					platTop<= 185-2;
			elsif((pR <= 75) and (pL >= 55) and (pT >= 435) and (pB <=475) and (coin1 = '1')) then ---- coin 1
					coin1 <= '0';
					count <= count +1;
				elsif((pR <= 265) and (pL >= 245) and (pT >= 165) and (pB <= 190) and (coin2 = '1')) then  ---- coin 2
					coin2 <= '0';
					count <= count +1;
				elsif((pR <= 130) and (pL >= 110) and (pT >= 450) and (pB <= 480) and (coin3 = '1')) then  ---- coin 3
					coin3 <= '0';	
					count <= count +1;		
				elsif((pR <= 225) and (pL >= 205) and (pT >= 440) and (coin4 = '1')) then  ---- coin 4
				coin4 <= '0';
				count <= count +1;
				elsif((pR <= 310) and (pL >= 285) and (pT >= 440) and (coin5 = '1')) then  ---- coin 5
					coin5 <= '0';	
					count <= count +1;
				elsif((pR <= 505) and (pL >= 475) and (pB >= 185) and (pT <= 210) and (coin7 = '1')) then   ---- coin 7
					coin7 <= '0';	
						count <= count +1;
				elsif((pR <= 525) and (pL >= 495) and (pT >= 235) and (pB <= 265) and (coin8 = '1')) then   ---- coin 8
					coin8 <= '0';
					count <= count +1;
				elsif((pR <= 440) and (pL >= 410) and (pT >= 450) and (pB <= 480) and (coin9 = '1')) then   ---- coin 9
					coin9 <= '0';
					count <= count +1;
				elsif((pR <= 75) and (pL >= 45) and (pB <= 445) and (pT >=415) and (coin10 = '1')) then   ---- coin 10
					coin10 <= '0';
					count <= count +1;				
			else
				onPlatform <= '0';
				platLBound <= 0;
				platRBound <= 0;
				platTop <= 0;
			end if;
		elsif(stage = s2) then
		if ((pR > 365 and pL < 405) and (pB < 440 and pT > 410))then --plat1
					platRBound <= 405;
					platLBound <= 365;
					onPlatform <= '1';
					platTop<= 440-2;
					
		elsif ((pR > 200 and pL < 280) and (pB < 430 and pT > 400))then --plat2
					platRBound <= 240;
					platLBound <= 200;
					onPlatform <= '1';
					platTop<= 430-2;
					
		elsif ((pR > 50 and pL < 120) and (pB < 415 and pT > 385))then --plat3
					platRBound <= 120;
					platLBound <= 50;
					onPlatform <= '1';
					platTop<= 415-3;
					
		--elsif((pR > 50 and pL < 90) and (pB < 360 and pT > 300)) then --plat4
					--platRBound <= 90;
					--platLBound <= 50;
					--onPlatform <= '1';
					--platTop<= 360-2;
					
		elsif((pR > 120 and pL < 200) and (pB < 360 and pT > 300)) then --plat5
					platRBound <= 200;
					platLBound <= 120;
					onPlatform <= '1';
					platTop<= 360-2;
					
		elsif((pR > 270 and pL < 340) and (pB < 320 and pT > 270)) then --plat6
					platRBound <= 340;
					platLBound <= 270;
					onPlatform <= '1';
					platTop<= 320-2;
					
		elsif((pR > 190 and pL < 230) and (pB < 280 and pT > 220)) then --plat7
					platRBound <= 230;
					platLBound <= 190;
					onPlatform <= '1';
					platTop<= 280-2;
					
		elsif((pR > 100 and pL < 160) and (pB < 250 and pT > 200)) then --plat8
					platRBound <= 160;
					platLBound <= 100;
					onPlatform <= '1';
					platTop<= 250-2;
					
		elsif((pR > 220 and pL < 270) and (pB < 225 and pT > 175)) then --plat9
					platRBound <= 270;
					platLBound <= 220;
					onPlatform <= '1';
					platTop<= 225-2;
					
		elsif((pR > 300 and pL < 365) and (pB < 185 and pT > 120)) then --plat10
					platRBound <= 365;
					platLBound <= 300;
					onPlatform <= '1';
					platTop<= 185-2;
					
		elsif((pR > 407 and pL < 417) and (pB < 170 and pT > 120)) then --Wall
					platRBound <= 417;
					platLBound <= 407;
					onPlatform <= '1';
					platTop<= 170-2;
					
		elsif((pR > 440 and pL < 450) and (pB < 160 and pT > 120)) then --plat 1 over fire
					platRBound <= 450;
					platLBound <= 440;
					onPlatform <= '1';
					platTop<= 160-2;
					
		elsif((pR > 520 and pL < HD) and (pB < 150 and pT > 100)) then --plat 2 over fire
					platRBound <= 450;
					platLBound <= 440;
					onPlatform <= '1';
					platTop<= 150-2;
					
------------------------------------------------------------------------------- coins stage 2 detector				
		elsif((pL >= 365) and (pR <= 395 ) and (pB <= 450) and (pT >= 420) and (coins2_1 = '1')) then ---- coin 1
			coins2_1 <= '0';
			count <= count +1;
		elsif((pL >= 215) and (pR <= 255 ) and (pB <= 440) and (pT >= 390) and (coins2_4 = '1')) then ---- coin 4
			coins2_4 <= '0';	
			count <= count +1;
		elsif((pL >= 45) and (pR <= 75) and (pB <= 415) and (pT <= 385) and (coins2_2 = '1')) then ---- coin 2
			coins2_2 <= '0';	
			count <= count +1;
		elsif((pL >= 110) and (pR <= 135) and (pT >= 330) and (pB <= 355) and (coins2_3 = '1')) then  ---- coin 3
			coins2_3 <= '0';	
			count <= count +1;
		elsif((pL >= 220) and (pR <= 260) and (pB <= 230) and (pT >= 190) and (coins2_7 = '1')) then   ---- coin 7
			coins2_7 <= '0';
			count <= count +1;
		elsif((pL >= 470) and (pR <=495 ) and (pT >= 115) and (pB <= 140) and (coins2_9 = '1')) then   ---- coin 9
			coins2_9 <= '0';
			count <= count +1;
		else
				onPlatform <= '0';
				platLBound <= 0;
				platRBound <= 0;
				platTop <= 0;
		end if;		
		if(count > "1010") then
			count <= "0001";
		else
			count<= count;
		end if;
	end if;
end process;


S: Score port map(count => count,rst => RST,d1=>d1,d2=>d2);



end Behavioral;




