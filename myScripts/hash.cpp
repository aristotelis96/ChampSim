

#include <iostream>
#include <fstream>
#include <functional>

using namespace std;

template <class T>
inline void hash_combine(std::size_t& seed, const T& v)
{
    std::hash<T.ip> hasher;
    seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
    
    std::hash<T.taken> hasher2;
    seed ^= hasher2(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
}

int main(){
    ifstream myfile;
    myfile.open("results/Dataset/output2.txt");
    string line;
    getline(myfile, line);
    while(line.compare(" --- H2P ---")!=0){
        getline(myfile, line);
    }
    size_t seed =0;
    getline(myfile, line);
    while(line.compare("--- H2P ---")!=0){
        getline(myfile, line);
        hash_combine(seed, line);
    }
    cout << seed << endl;
    getline(myfile, line);
    seed=0;
    while(line.compare("--- H2P ---")!=0){
        getline(myfile, line);
        hash_combine(seed, line);
    }
    cout << seed << endl;
    getline(myfile, line);
    seed=0;
    while(line.compare("--- H2P ---")!=0){
        getline(myfile, line);
        hash_combine(seed, line);
    }
    cout << seed << endl;
    return 0;
}   