#ifndef __BBV_FILE_FORMAT_HH__
#define __BBV_FILE_FORMAT_HH__

#include <cstdint>
#include <cstdlib>
#
#include <string>
#include <ostream>
#include <fstream>
#include <sstream>
#include <map>

class bbv_file {
    public:
        bbv_file () = default;

        bbv_file (const std::string &filepath) {
            this->open (filepath);
        }

        ~bbv_file () {
            if (this->_output_file) {
                this->_output_file << std::flush;
                this->_output_file.close ();
            }
        }

        void open (const std::string& filepath) {
            // Let's try to open the designated file.
            this->_output_file.open (filepath.c_str ());

            if (!this->_output_file.is_open ()) {
                std::cerr << "[ERROR] Unable to open the provided output file: " << filepath << "." << std::endl;
                std::exit (1);
            }
        }

        void add_count (const uint64_t& ip) {
            std::map<uint64_t, std::size_t>::iterator it;
            
            // Checking if the entry exists in the occurancy counters vector.
            if ((this->_branch_counts.find (ip)) == this->_branch_counts.end ()) {
                this->_branch_counts[ip] = 0x0;
            }

            this->_branch_counts[ip]++;
        }

        void reset_counters () {
            for (auto& e : this->_branch_counts) {
                e.second = 0x0;
            }
        }

        void write_counters () {
            std::size_t bb_idx = 0x1;

            this->_output_file << "T";

            for (const auto& e : this->_branch_counts) {
                if (e.second > 0) {
                    this->_output_file << ":" << bb_idx << ":"
                                       << e.second << " ";
                }

                bb_idx++;
            }

            this->_output_file << std::endl;
        }
    
    private:
        std::ofstream _output_file;
        std::map<uint64_t, std::size_t> _branch_counts;
};

#endif // __BBV_FILE_FORMAT_HH__
