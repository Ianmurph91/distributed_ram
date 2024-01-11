-- Dual-Port Distributed RAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity RAM is
    generic (
        RAM_DEPTH   : integer := 256;
        RAM_WIDTH   : integer := 16;
        ADDR_WIDTH  : integer := 8 -- should be set to ceil(log2(real(RAM_DEPTH))) in top level
    );
    port ( 
        clk_wr      : in std_logic;
        clk_rd      : in std_logic;
        aresetn     : in std_logic;
        write_en    : in std_logic;
        read_en     : in std_logic;
        addr_wr     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        addr_rd     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data_in     : in std_logic_vector(RAM_WIDTH-1 downto 0);
        data_out    : out std_logic_vector(RAM_WIDTH-1 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

    type ram_type is array (RAM_DEPTH-1 downto 0) of std_logic_vector(RAM_WIDTH-1 downto 0);
    signal RAM : ram_type;

    begin

        ram_write : process(clk_wr) begin
            if(aresetn = '0') then
                RAM <= (others => (others => '0'));
            elsif rising_edge(clk_wr) then
                if (write_en = '1') then
                    RAM(to_integer(unsigned(addr_wr))) <= data_in;
                end if;
            end if;
        end process;

        ram_read : process(clk_rd) begin
            if(aresetn = '0') then
                data_out <= (others => '0');
            elsif rising_edge(clk_rd) then
                if (read_en = '1') then
                    data_out <= RAM(to_integer(unsigned(addr_rd)));
                end if;
            end if;
        end process;

        

end Behavioral;
