module HazardUnit(
    input        id_ex_mem_read,
    input  [4:0] id_ex_rt,
    input  [4:0] if_id_rs,
    input  [4:0] if_id_rt,
    input        if_id_uses_rs,
    input        if_id_uses_rt,
    input        if_id_jump_reg,
    input        id_ex_reg_write,
    input  [4:0] id_ex_write_reg,
    input        ex_mem_reg_write,
    input  [4:0] ex_mem_write_reg,
    output       stall
);

    wire load_use_rs;
    wire load_use_rt;
    wire jump_reg_wait_ex;
    wire jump_reg_wait_mem;

    assign load_use_rs = id_ex_mem_read && if_id_uses_rs && id_ex_rt != 5'd0 && id_ex_rt == if_id_rs;
    assign load_use_rt = id_ex_mem_read && if_id_uses_rt && id_ex_rt != 5'd0 && id_ex_rt == if_id_rt;

    assign jump_reg_wait_ex  = if_id_jump_reg && id_ex_reg_write &&
                               id_ex_write_reg != 5'd0 && id_ex_write_reg == if_id_rs;
    assign jump_reg_wait_mem = if_id_jump_reg && ex_mem_reg_write &&
                               ex_mem_write_reg != 5'd0 && ex_mem_write_reg == if_id_rs;

    assign stall = load_use_rs || load_use_rt || jump_reg_wait_ex || jump_reg_wait_mem;

endmodule
