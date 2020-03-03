#ifndef BRANCHSTATISTICS_H
#define BRANCHSTATISTICS_H

#include <unordered_map>
#include <fstream>

using namespace std;

typedef struct stats {
    long long counter;
    long long misspredictions;
} stats;

class BRANCHSTATISTICS {
    private:
        unordered_map<uint64_t, stats> branches;
        vector<uint64_t> IPs;
        long long reset_window, accuracy, occurrences, misspredictions;
        long long instr_counter;
        long long total_branches = 0, h2p = 0;
        

    public:    
        // Constructor with accuracy, occurrences, misspredictions, reset_window values initialized in order to identify candidate branch as Hard-to-Predict
        BRANCHSTATISTICS(long long accur, long long occur, long long miss, long long reset){
            accuracy = accur;
            occurrences = occur;
            misspredictions = miss;
            reset_window = reset;
            instr_counter = 0;
        }
        // Costructor without accuracy, occurrences, misspredictions, reset_window values initialized, use only as data structure for H2P branches
        BRANCHSTATISTICS(){            
            accuracy=100;
            occurrences=0;
            misspredictions=0;
            reset_window=0;
        }
        ~BRANCHSTATISTICS(){
            ;            
        }

        void countH2P_and_clear(){
            for (unordered_map<uint64_t, stats>::iterator itr = branches.begin(); itr != branches.end(); itr++){                
                if ((double)itr->second.misspredictions / (double)itr->second.counter <= accuracy && itr->second.counter >= occurrences && itr->second.misspredictions >= misspredictions){
                    h2p++;                    
                    IPs.push_back(itr->first);
                }
            } 
            total_branches += branches.size();
            branches.clear();
            instr_counter = 0;
        }
        // Method to simply add H2P without checking if already inside structure
        void add(uint64_t ip){
            stats stat = {1, 1};
            pair<unordered_map<uint64_t,stats>::iterator,bool> ret;

            ret = branches.insert( pair<uint64_t, stats>(ip, stat));
        }
        // Method to add/modify a H2P with statistics
        void add(uint64_t ip, bool missprediction){
            stats stat = {1, 1};
            pair<unordered_map<uint64_t,stats>::iterator,bool> ret;
            ret = branches.insert( pair<uint64_t, stats>(ip, stat));
            if (ret.second == false){
                // if already inside the map, increase counters instead
                branches[ip].counter ++;
                if (missprediction == false){
                    // if missprediction, increase miss counter
                    branches[ip].misspredictions++;
                }
            }
            if (reset_window != 0){
                instr_counter++;
                if (instr_counter == reset_window){
                    countH2P_and_clear();
                }
            }
        }

        //Method to check if IP is stored
        bool contain(uint64_t ip){
            if (branches.count(ip)>0)
                return true;
            else
                return false;
        }

        void printH2P(){            
            // Count remaining H2P
            countH2P_and_clear();

            cout << "Hard-to-Predict branches found: " << h2p << endl;            
            cout << "Total branches screened: " << total_branches << endl;
        }
        
        void printIPs(){
            // Count remaining H2P
            countH2P_and_clear();
            // Print IPs
            for(std::vector<uint64_t>::iterator it = IPs.begin(); it != IPs.end(); it++) {
                std::cout << *it << std::endl;
            }
        }
} ;

extern BRANCHSTATISTICS *branchstats;
extern bool doH2P;
extern string perfect_H2P_file;
#endif