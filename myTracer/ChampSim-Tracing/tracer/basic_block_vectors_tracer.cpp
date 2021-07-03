#include <iostream>
#include <fstream>
#include <sstream>
#
#include "bbv_file_format.hh"
#
#include <pin.H>

static UINT64 instr_count = 0;
static bbv_file output;

KNOB<std::string> KnobOutputFile(KNOB_MODE_WRITEONCE,  "pintool", "o", "champsim.trace",
        "specify file name for Champsim tracer output");
KNOB<UINT32> KnobInstructionPeriod(KNOB_MODE_WRITEONCE, "pintool", "p", "1000000000",
        "specify how long is the recording period for the basic blocks");

/**
 * @brief This function is the first called on an instrumented instruction. Based
 * on some information about the current instruction we start to fill an instruction
 * descriptor using the ChampSim format.
 *
 * @param ip The instruction pointer of this instruction.
 */
VOID BeginInstruction () {
    // When we encounter a new instruction, we increment this counter by one.
    instr_count++;
}

VOID EndInstruction () {
    // When we reach a certain number of instructions encountered we flush
    // the information about the basic blocks into the file.
    if ((instr_count % KnobInstructionPeriod.Value ()) == 0x0) {
        output.write_counters ();
        output.reset_counters ();
    }
}

VOID Branch (VOID* ip) {
    output.add_count (reinterpret_cast<uint64_t> (ip));
}

INT32 Usage () {
  std::cerr << "This tool creates a register and memory access trace" << std::endl
            << "Specify the output trace file with -o" << std::endl << std::endl;

  std::cerr << KNOB_BASE::StringKnobSummary() << std::endl;

  return -1;
}

VOID Instruction (INS ins, VOID* v) {
    // Before every single instruction that we encounter.
    INS_InsertCall (ins, IPOINT_BEFORE, static_cast<AFUNPTR> (BeginInstruction), IARG_END);

    // We are only instrumenting branches.
    if (INS_IsBranch (ins)) {
        INS_InsertCall (ins, IPOINT_BEFORE, (AFUNPTR) Branch, IARG_INST_PTR, IARG_END);
    }

    // After every single instruction that we encounter.
    INS_InsertCall (ins, IPOINT_BEFORE, static_cast<AFUNPTR>(EndInstruction), IARG_END);
}

VOID Fini (INT32 code, VOID *v) {
}

int main(int argc, char *argv[]) {
  std::stringstream output_file_stream;

  if (PIN_Init (argc, argv)) {
    return Usage ();
  }

  // Opening the output file.
  output_file_stream << /*"bbv/" <<*/ KnobOutputFile.Value () << ".bb";

  output.open (output_file_stream.str ());

  // Register function to be called to instrument instructions.
  INS_AddInstrumentFunction (Instruction, 0);

  PIN_AddFiniFunction (Fini, 0);

  // Start the program, never returns.
  PIN_StartProgram ();

  return 0;
}
