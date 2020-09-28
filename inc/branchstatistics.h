#ifndef BRANCHSTATISTICS_H
#define BRANCHSTATISTICS_H

#include <unordered_map>
#include <iostream>
#include <fstream>
#include <list>
#include <unordered_set>
#include <functional>
#include <time.h>

using namespace std;


extern bool doH2P;
extern string perfect_H2P_file;
extern bool H2P_predictor;
extern bool perfect_H2P;
extern bool collect_H2P_dataset;
extern bool dataset_unique_histories, dataset_random;
extern bool measure_H2P_accuracy;
extern long total_H2P, correct_H2P_predicted;
extern std::string PytorchName;

/* check statistics for each H2P by Tage Predictor */
typedef struct accuracyStat{
    long int total;
    long int correct;
} accuracyStat;
extern unordered_map<uint64_t, accuracyStat> H2PBranches;

/* Hash_Combine function */
template <class T>
inline void hash_combine(std::size_t& seed, const T& v)
{
    std::hash<T> hasher;
    seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
}

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
                if (1.0-((double)itr->second.misspredictions / (double)itr->second.counter) <= (double)accuracy/100.0 && itr->second.counter >= occurrences && itr->second.misspredictions >= misspredictions){
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
        }
        void count_instr(){
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

typedef struct ip_bool {
    uint64_t ip;
    bool taken;
} ip_bool;

class Branch_History {
    private:
        list<ip_bool> IPs;
        unordered_set<size_t> unique_hashes;
        unordered_map<uint64_t, long> H2PsStats;
    public:
        // Constructor
        Branch_History(){
            H2PsStats = {
                // ------ 600 210B----------
                // {4226075, 94243},
                // {4224005, 60603 },
                // {4976121, 5764991},
                // {5008304, 1950845},
                // {4295273, 202885 },
                // {5004294, 674328 },
                // {5015393, 2752803},
                // {5307410, 1464420},
                // {4957196, 127042 },
                // {4969208, 108379 },
                // {4978645, 2626290 },
                // {4999560, 98430}
                // -------- 631 ----------------
                {4198684, 1009548},
                {4198728, 833737},
                {4198880, 863879},
                {4198968, 854544},
                {4199008, 748933},
                {4199369, 1039561},
                {4199399, 1039561},
                {4199436, 1039561},
                {4199463, 1039561},
                {4207717, 5977343},
                {4207737, 5230741},
                {4218498, 659098},
                {4222641, 1241212},
                {4223266, 1237963},
                {4223606, 1112473},
                {4224257, 1241212},
                {4224568, 1240987},
                {4224786, 1237972},
                {4224891, 1238905},
                {4224901, 1021181},
                {4238165, 915302},
                {4238291, 920693},
                {4238434, 739246},
                {4238587, 676412},
                {4238628, 788647},
                {4246069, 815081},
                {4246120, 815081},
                {4246335, 815081},
                {4250377, 2246534},
                {4250535, 2263518},
                {4257928, 1039561},
                {4258021, 1007615}
            };
            // if using random
            if (dataset_random){
                srand(time(0));
            }
        }   
        //Destructor
        ;
        void add_branch(uint64_t ip, bool taken){
            // add pair of IP - Outcome to list
            ip_bool entry = {ip, taken};
            IPs.push_front(entry);
            // if list is bigger than 200 entries, delete last entry
            if(IPs.size()>200){
                IPs.pop_back();
            }
        }
        void print_history(uint64_t h2pIP, bool taken){
            // check if we already found this specific history
            // hash the whole history for this H2P branch and check if it has been stored
            size_t seed = 0;            
            if (dataset_unique_histories){
                // hash H2P ip with boolean value
                hash_combine(seed, h2pIP);
                hash_combine(seed, taken);
                //then hash history of h2p
                for (list<ip_bool>::iterator it = IPs.begin(); it != IPs.end(); it++){                            
                    hash_combine(seed, it->ip);
                    hash_combine(seed, it->taken);
                }
            }
            if (dataset_unique_histories) {
                if(unique_hashes.find(seed)==unique_hashes.end()){            
                    // append to file if not in set and add to set
                    unique_hashes.insert(seed);
                    ofstream myfile;
                    myfile.open("test.txt", ios::app);
                    // Print --- H2P --- and the h2p with its boolean
                    cout << "--- H2P ---" << endl;
                    cout << h2pIP << " " << taken << endl;
                    // Then print history
                    for (list<ip_bool>::iterator it = IPs.begin(); it != IPs.end(); it++){                    
                        cout << it->ip << " " << it->taken << endl;
                    }
                    myfile.close();
                }
            } else if (dataset_random){          
                long h2p_total_occurences = H2PsStats[h2pIP];      
                double probability = (5000.0 / (double)h2p_total_occurences)*1000;
                double guess = (double)(rand() % 1000);
                bool useH2P = (guess) < probability;
                // if the probability is good, count H2P
                if (useH2P){
                    ofstream myfile;
                    myfile.open("test.txt", ios::app);
                    // Print --- H2P --- and the h2p with its boolean
                    cout << "--- H2P ---" << endl;
                    cout << h2pIP << " " << taken << endl;
                    // Then print history
                    for (list<ip_bool>::iterator it = IPs.begin(); it != IPs.end(); it++){                    
                        cout << it->ip << " " << it->taken << endl;
                    }
                    myfile.close();       
                }
            } else{
                ofstream myfile;
                myfile.open("test.txt", ios::app);
                // Print --- H2P --- and the h2p with its boolean
                cout << "--- H2P ---" << endl;
                cout << h2pIP << " " << taken << endl;
                // Then print history
                for (list<ip_bool>::iterator it = IPs.begin(); it != IPs.end(); it++){                    
                    cout << it->ip << " " << it->taken << endl;
                }
                myfile.close();   
            }
        }
        
};


extern BRANCHSTATISTICS *branchstats;
extern Branch_History *branch_history;
#endif