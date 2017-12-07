library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Score is
	port(
		count: in std_logic_vector(3 downto 0);
		rst : in std_logic;
		d1 : out std_logic_vector(6 downto 0);
		d2 : out std_logic_vector(6 downto 0)
	);
end entity;


architecture behavioral of Score is
signal tens: std_logic_vector(3 downto 0);
signal ones: std_logic_vector(3 downto 0);

begin
counter: process(count,rst, ones, tens)
begin
	if(rst = '1') then
	 tens <= (others=>'0');
	elsif (count >= "1010") then
		tens<= tens +1;
		ones<= (others=>'0');
	else
		tens<= tens;
		ones<= count;
	end if;
	d1(0)<= not(ones(3) or ones(1) or (ones(2) and ones(0)) or (not ones(2) and not ones(0)));
	d1(1)<= not(not ones(2) or (not ones(1) and not ones(0)) or (ones(1) and ones(0)));
	d1(2)<= not(ones(2) or not ones(1) or ones(0));
	d1(3)<= not((not ones(2) and not ones(0)) or(ones(1) and not ones(0)) or (ones(2) and not ones(1) and ones(0)) or (not ones(2) and ones(1)) or ones(3));
	d1(4)<= not((not ones(2) and not ones(0)) or (ones(1) and not ones(0)));
	d1(5)<= not(ones(3) or (not ones(1) and not ones(0)) or (ones(2) and not ones(1)) or (ones(2) and not ones(0)));
	d1(6)<= not(ones(3) or (ones(2) and not ones(1)) or (not ones(2) and ones(1)) or (ones(1) and not ones(0)));
	
	d2(0)<= not(tens(3) or tens(1) or (tens(2) and tens(0)) or (not tens(2) and not tens(0)));
	d2(1)<= not(not tens(2) or (not tens(1) and not tens(0)) or (tens(1) and tens(0)));
	d2(2)<= not(tens(2) or not tens(1) or tens(0));
	d2(3)<= not((not tens(2) and not tens(0)) or(tens(1) and not tens(0)) or (tens(2) and not tens(1) and tens(0)) or (not tens(2) and tens(1)) or tens(3));
	d2(4)<= not((not tens(2) and not tens(0)) or (tens(1) and not tens(0)));
	d2(5)<= not(tens(3) or (not tens(1) and not tens(0)) or (tens(2) and not tens(1)) or (tens(2) and not tens(0)));
	d2(6)<= not(tens(3) or (tens(2) and not tens(1)) or (not tens(2) and tens(1)) or (tens(1) and not tens(0)));
	
	
end process;

	
		


end architecture; 