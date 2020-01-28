#ifndef BRANCHSTATISTICS_H
#define BRANCHSTATISTICS_H

#include <unordered_map>

using namespace std;

typedef struct stats {
    long int counter;
    long int misspredictions;
} stats;

class BRANCHSTATISTICS {
    private:
        unordered_map<uint64_t, stats> branches;
        pair<unordered_map<uint64_t,stats>::iterator,bool> ret;

    public:
        void add(uint64_t ip, bool missprediction){
            stats stat = {1, 1};
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

        void printH2P(uint64_t accuracy, uint64_t occurrences, uint64_t misspredictions){
            unordered_map<uint64_t, stats>::iterator itr;
            long int h2p = 0;
            for (itr = branches.begin(); itr != branches.end(); itr++){
                if ((double)itr->second.misspredictions / (double)itr->second.counter <= accuracy && itr->second.counter > occurrences && itr->second.misspredictions > misspredictions){
                    h2p++;                    
                }
            }
            cout << h2p << endl;
        }
} ;

extern BRANCHSTATISTICS branchstats;

#endif