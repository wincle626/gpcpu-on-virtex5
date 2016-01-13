library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity ALU is
    port (
      A : in Tdata;
      B : in Tdata;
      S : in std_logic_vector(2 downto 0);
      
      Q : out Tdata;
      Z_OUT : out std_logic
    );
end entity ALU;

architecture behaviour of ALU is
begin
  with S select Q <= std_logic_vector( signed(A) + signed(B) ) when "000",
                     std_logic_vector( signed(A) - signed(B) ) when "001",
                     A and B when "010",
                     A or B when "011",
                     not A when "101",
                     std_logic_vector( shift_left(signed(A), to_integer(signed(B))) ) when "110",
                     std_logic_vector( shift_right(signed(A), to_integer(signed(B))) ) when "111",
                     x"00000000" when others;
                
  Z_OUT <= '1' when B = x"00000000" else
           '0';
end architecture behaviour;
