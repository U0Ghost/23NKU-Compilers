#include <algorithm>
#include <fstream>
#include <iostream>
#include <set>
#include <unordered_set>
#include <map>
#include <memory>
#include <queue>
#include <stack>
#include <string>
#include <utility>
#include <vector>

using std::endl;
using std::cout;
using std::set;
using std::unordered_set;
using std::map;
using std::ifstream;
using std::ofstream;

using std::queue;
using std::shared_ptr;
using std::stack;
using std::string;
using std::vector;
using std::make_shared;

class NFAAlgorithm {
public:
    string symbols;
    string regex;
    string postfix;

    enum class OP {
        BRACKET,
        OR,
        CONNECT,
        STAR,
    };

    struct Edge;
    int gID = 0;
    struct Node {
        int id; // Node 编号
        bool is_end;  // 添加了终止状态的标志
        bool visited; // 用于输出时判断是否访问过
        vector<shared_ptr<Edge>> out_edges;
        Node() { id = -1; is_end = false; visited = false; };
    };

    static constexpr char EPSILON = '~';
    struct Edge {
        shared_ptr<Node> from;
        shared_ptr<Node> to;
        char symbol;
        bool isE;
        Edge() { isE = false; }
        Edge(shared_ptr<Node> from, shared_ptr<Node>to, char symbol, bool isE = false) : from(from), to(to), symbol(symbol), isE(isE) {}
    };

    struct NFA {
        shared_ptr<Node> start;
        shared_ptr<Node> end;

        NFA(shared_ptr<Node> start, shared_ptr<Node> end) : start(std::move(start)), end(std::move(end)) {}
    };
    shared_ptr<NFA> nfa;

    explicit NFAAlgorithm(string symbols, string& regex) : symbols(std::move(symbols)), regex(regex) {
        add_connect_op();
        re2post();
        build_nfa();
    };

    static OP get_op(char cur_char) {
        switch (cur_char) {
        case '|':
            return OP::OR;
        case '.':
            return OP::CONNECT;
        case '*':
            return OP::STAR;
        case '(':
        case ')':
            return OP::BRACKET;
        default:
            return OP::CONNECT;
        }
    }

    bool is_in_symbols(char cur_char) { return symbols.find(cur_char) != std::string::npos; }

    /** NFA构建用的函数 */
    /*
    * 处理[]中的-
    */

    string parse_range(string str) {

        if (str.size() == 1) return str;
        string range;
        for (size_t i = 0; i < str.size(); ++i) {
            if (i + 1 < str.size() and str[i + 1] == '-') {  // 识别到一个范围
                for (auto x = str[i]; x <= str[i + 2]; ++x) {
                    range += x;
                }
                i += 2;
            }
            else {
                range += str[i];
            }
        }
        return range;
    }

    /**
     * 为了转后缀表达式方便，添加了 . 连接符
     *
     */
    void add_connect_op() {
        //处理[]
        string prexp, middle;
        bool is_mid = false;
        for (auto c : regex) {
            if (c == '[') {
                is_mid = true;
                prexp.push_back('(');
            }
            else if (c == ']') {
                string mid = parse_range(middle);
                for (auto m : mid) {
                    prexp += m;
                    prexp += '|';
                }
                prexp.pop_back();
                prexp.push_back(')');
                middle = ""; //重置middle
                is_mid = false;
            }
            else {
                if (is_mid)
                    middle += c;
                else
                    prexp += c;
            }
        }
        // cout << "prexp: " << prexp << endl;
        regex = prexp;

        string new_regex;
        for (int i = 0; i < regex.size() - 1; i++) {
            auto flag1 = is_in_symbols(regex[i]);
            auto flag2 = is_in_symbols(regex[i + 1]);
            if ((flag1 && regex[i + 1] == '(') || (flag1 && flag2) || (regex[i] == ')' && flag2) || (regex[i] == '*' && flag2)) {
                new_regex += regex[i];
                new_regex += '.';
            }
            else if (regex[i] == '*' && regex[i + 1] == '(') {
                new_regex += regex[i];
                new_regex += '.';
            }
            else {
                new_regex += regex[i];
            }
        }

        new_regex += regex.back();

        regex = new_regex;
    }

    /**
     * 转后缀表达式
     *
     */
    void re2post() {
        stack<char> opStack;
        for (auto& cur_char : regex) {
            if (is_in_symbols(cur_char)) {
                postfix += cur_char;
            }
            else if (cur_char == '(') {
                opStack.push(cur_char);
            }
            else if (cur_char == ')') {
                while (opStack.top() != '(') {
                    postfix += opStack.top();
                    opStack.pop();
                }
                opStack.pop();
            }
            else {
                while (!opStack.empty() && get_op(opStack.top()) >= get_op(cur_char)) {
                    postfix += opStack.top();
                    opStack.pop();
                }
                opStack.push(cur_char);
            }
        }
        while (!opStack.empty()) {
            postfix += opStack.top();
            opStack.pop();
        }
    }
    /**
     * 创建nfa的函数集，包括带边的和'.' '|' '*'三种情况。
     *
     */

    shared_ptr<NFA> create_basic_nfa(char symbol) {
        auto start = make_shared<Node>();
        auto end = make_shared<Node>();
        auto edge = make_shared<Edge>();
        start->id = gID++;
        end->id = gID++;
        end->is_end = true; // 记得每次修改nfa时将对应的初始状态和终止状态标记维护
        edge->from = start;
        edge->to = end;
        edge->symbol = symbol;
        if (symbol == '~') { edge->isE = true; }
        start->out_edges.push_back(edge);
        return make_shared<NFA>(start, end);
    }

    shared_ptr<NFA> or_nfa(shared_ptr<NFA> nfa1, shared_ptr<NFA> nfa2) {
        auto start = make_shared<Node>();
        auto end = make_shared<Node>();
        auto edge1 = make_shared<Edge>();
        start->id = gID++;
        end->id = gID++;
        edge1->from = start;
        edge1->to = nfa1->start;
        edge1->symbol = EPSILON;
        auto edge2 = make_shared<Edge>();
        edge2->from = start;
        edge2->to = nfa2->start;
        edge2->symbol = EPSILON;
        auto edge3 = make_shared<Edge>();
        edge3->from = nfa1->end;
        edge3->to = end;
        edge3->symbol = EPSILON;
        auto edge4 = make_shared<Edge>();
        edge4->from = nfa2->end;
        edge4->to = end;
        edge4->symbol = EPSILON;
        start->out_edges.push_back(edge1);
        start->out_edges.push_back(edge2);

        nfa1->end->out_edges.push_back(edge3);
        nfa2->end->out_edges.push_back(edge4);
        nfa1->end->is_end = false;
        nfa2->end->is_end = false;
        end->is_end = true;
        return make_shared<NFA>(start, end);
    }

    shared_ptr<NFA> connect_nfa(shared_ptr<NFA> nfa1, shared_ptr<NFA> nfa2) {
        nfa1->end->is_end = false;
        auto edge1 = make_shared<Edge>();
        //bool nfa1E = nfa1->start->out_edges.size() == 1 && nfa1->start->out_edges[0]->symbol == '~';
        //bool nfa2E = nfa2->start->out_edges.size() == 1 && nfa2->start->out_edges[0]->symbol == '~';
        //if(nfa1E){
        //    edge1->from = nfa1->start;
        //    nfa1->start->out_edges.pop_back();
        //}
        //else{
        //    edge1->from = nfa1->end;}
        //if (nfa2E) {
        //    edge1->to = nfa2->start->out_edges[0]->to;
        //    nfa2->start->out_edges.pop_back();
        //}
        //else {
        //    edge1->to = nfa2->start;
        //}
        edge1->from = nfa1->end;
        edge1->to = nfa2->start;
        edge1->symbol = EPSILON;


        nfa1->end->out_edges.push_back(edge1);
        return make_shared<NFA>(nfa1->start, nfa2->end);
    }

    shared_ptr<NFA> star_nfa(shared_ptr<NFA> nfa1) {
        auto start = make_shared<Node>();
        auto end = make_shared<Node>();
        start->id = gID++;
        end->id = gID++;
        auto edge1 = make_shared<Edge>();
        edge1->from = start;
        edge1->to = end;
        edge1->symbol = EPSILON;
        auto edge2 = make_shared<Edge>();
        edge2->from = start;
        edge2->to = nfa1->start;
        edge2->symbol = EPSILON;
        auto edge3 = make_shared<Edge>();
        edge3->from = nfa1->end;
        edge3->to = nfa1->start;
        edge3->symbol = EPSILON;
        auto edge4 = make_shared<Edge>();
        edge4->from = nfa1->end;
        edge4->to = end;
        edge4->symbol = EPSILON;
        start->out_edges.push_back(edge1);
        start->out_edges.push_back(edge2);
        nfa1->end->out_edges.push_back(edge3);
        nfa1->end->out_edges.push_back(edge4);
        nfa1->end->is_end = false;
        end->is_end = true;

        return make_shared<NFA>(start, end);
    }

    /*
    * 建立nfa过程，按后缀表达式机器处理的顺序做，同时合并nfa
    * 缺点是添加.的也会变成中缀表达式的一部分。
     */
    void build_nfa() {
        stack<shared_ptr<NFA>> nfaStack;
        for (char c : postfix) {
            if (is_in_symbols(c)) {
                nfaStack.push(create_basic_nfa(c));
            }
            else {
                switch (c) {
                case '|': {
                    auto nfa2 = nfaStack.top();
                    nfaStack.pop();
                    auto nfa1 = nfaStack.top();
                    nfaStack.pop();
                    nfaStack.push(or_nfa(nfa1, nfa2));
                    break;
                }
                case '.': {
                    auto nfa2 = nfaStack.top();
                    nfaStack.pop();
                    auto nfa1 = nfaStack.top();
                    nfaStack.pop();
                    nfaStack.push(connect_nfa(nfa1, nfa2));
                    break;
                }
                case '*': {
                    auto nfa1 = nfaStack.top();
                    nfaStack.pop();
                    nfaStack.push(star_nfa(nfa1));
                    break;
                }
                default: {
                    auto nfa2 = nfaStack.top();
                    nfaStack.pop();
                    auto nfa1 = nfaStack.top();
                    nfaStack.pop();
                    nfaStack.push(connect_nfa(nfa1, nfa2));
                    break;
                }

                }
            }
        }
        nfa = nfaStack.top();
    }

    /**
     * 输出NFA到DOT文件
     */

    void output_nfa_to_dot(const string& filename) {
        ofstream dotFile(filename);
        dotFile << "digraph NFA {" << endl;
        dotFile << "  rankdir=LR;" << endl;

        stack<shared_ptr<Node>> nodeStack;
        stack<char> symbolStack;

        auto visit = [&](shared_ptr<Node> node) {
            if (node->id == -1) {
                node->id = gID++;
                nodeStack.push(node);
            }
            else
                nodeStack.push(node);
        };

        visit(nfa->start);

        while (!nodeStack.empty()) {
            auto node = nodeStack.top();
            if (node->visited) { nodeStack.pop(); continue; }
            else { node->visited = true; }
            nodeStack.pop();
            dotFile << "  " << node->id;
            if (node->is_end) {
                dotFile << " [shape=doublecircle]";
            }
            dotFile << " [label=\"" << node->id << "\"];" << endl;
            for (const auto& edge : node->out_edges) {
                dotFile << "  " << node->id << " -> " << edge->to->id << " [label=\"" << edge->symbol << "\"];" << endl;
                visit(edge->to);
            }
        }

        dotFile << "}" << endl;
        dotFile.close();
    }

};



class DFA {
public:
    struct State {
        int id;
        bool is_end;
        map<char, State*> transitions;

        State(int id, bool is_end = false) : id(id), is_end(is_end) {}
    };



    DFA(const vector<char>& symbols, shared_ptr<NFAAlgorithm::NFA> nfa) {
        build_dfa(symbols, nfa);
        //output_dfa_to_dot("dfa.dot");
        //minimize();
    }

    /*
    * dfa构建过程
    */
    void build_dfa(const vector<char>& symbols, shared_ptr<NFAAlgorithm::NFA> nfa) {
        int state_id = 0;
        set<shared_ptr<NFAAlgorithm::Node>> start_state; //接收NFA的开始状态
        start_state = { nfa->start };
        start_state = e_closure(start_state);

        State* start = new State(state_id++);
        start->is_end = contains_end_state(start_state);
        dfa_states[start_state] = start;

        vector<set<shared_ptr<NFAAlgorithm::Node>>> dfa_state_set;
        dfa_state_set.push_back(start_state);

        queue<set<shared_ptr<NFAAlgorithm::Node>>> state_queue;
        state_queue.push(start_state);

        while (!state_queue.empty()) {
            set<shared_ptr<NFAAlgorithm::Node>> current_state = state_queue.front();
            state_queue.pop();

            for (char symbol : symbols) {
                set<shared_ptr<NFAAlgorithm::Node>> next_state;
                for (const auto& node : current_state) {
                    auto transitions = get_transitions(node, symbol);
                    next_state.insert(transitions.begin(), transitions.end());
                }

                if (!next_state.empty()) {
                    next_state = e_closure(next_state);
                    //cout << "next_state:" << dfa_state_to_string(next_state) << endl;
                    if (dfa_states.find(next_state) == dfa_states.end()) {
                        State* new_state = new State(state_id++);
                        new_state->is_end = contains_end_state(next_state);
                        dfa_states[next_state] = new_state;
                        dfa_state_set.push_back(next_state);
                        state_queue.push(next_state);
                    }
                    dfa_states[current_state]->transitions[symbol] = dfa_states[next_state];
                }
            }
        }

        this->start_state = start;
    }

    /**
    * 最小化(uncompleted)
    */

    void minimize() {
        // 分成终态和非终态 分别进行三重遍历
        vector<State*> states;

        for (const auto& kv : dfa_states) {
            states.push_back(kv.second);
        }

        vector<set<State*>> equivalence_classes;
        set<State*> accepting_states;
        set<State*> non_accepting_states;

        for (State* state : states) {
            if (state->is_end) {
                accepting_states.insert(state);
            }
            else {
                non_accepting_states.insert(state);
            }
        }

        if (!accepting_states.empty()) {
            equivalence_classes.push_back(accepting_states);
        }
        if (!non_accepting_states.empty()) {
            equivalence_classes.push_back(non_accepting_states);
        }

        bool changed = true;
        int round = 0;
        while (changed) {
            changed = false;
            vector<set<State*>> new_equivalence_classes;

            for (set<State*> equiv_class : equivalence_classes) {
                if (equiv_class.size() <= 1) {
                    new_equivalence_classes.push_back(equiv_class);
                }
                else {
                    bool split = false;  // Flag to indicate if any split occurred

                    set<char> symbols;
                    for (State* state : equiv_class) {
                        for (const auto& transition : state->transitions) {
                            symbols.insert(transition.first);
                        }
                    }
                    std::cout << "round " << ++round << " state num:" << equivalence_classes.size() << endl;
                    for (char symbol : symbols) {
                        if (split) break;
                        set<State*> split1;
                        set<State*> split2;

                        for (State* state : equiv_class) {
                            State* next_state = state->transitions[symbol];
                            if (split1.find(next_state) != split1.end()) {
                                split1.insert(state);
                                std::cout << state->id << " insert in split1 " << endl;
                            }
                            else if (split2.find(next_state) != split2.end()) {
                                split2.insert(state);
                                std::cout << state->id << " insert in split2 " << endl;
                            }
                            else {
                                split1.insert(state);
                                std::cout << state->id << " insert in split1 " << endl;
                            }

                        }

                        if (!split1.empty() && !split2.empty()) {
                            new_equivalence_classes.push_back(split1);
                            new_equivalence_classes.push_back(split2);
                            split = true;
                        }
                    }

                    if (!split) {
                        new_equivalence_classes.push_back(equiv_class);
                    }
                    else {
                        changed = true;
                    }
                }
            }

            equivalence_classes = new_equivalence_classes;
        }

        // 基于等价类更新DFA
        map<State*, State*> equivalent_state;
        for (const set<State*>& equiv_class : equivalence_classes) {
            State* representative = *equiv_class.begin();
            for (State* state : equiv_class) {
                equivalent_state[state] = representative;
            }
        }

        for (State* state : states) {
            for (auto& transition : state->transitions) {
                transition.second = equivalent_state[transition.second];
            }
        }

        // 更新起始状态
        start_state = equivalent_state[start_state];
    }

    void output_dfa_to_dot(const string& filename) {
        ofstream dotFile(filename);
        dotFile << "digraph DFA {" << endl;
        dotFile << "  rankdir=LR;" << endl;

        for (const auto& state : this->get_states()) {
            dotFile << "  " << state->id;
            if (state->is_end) {
                dotFile << " [shape=doublecircle]";
            }
            dotFile << " [label=\"" << state->id << "\"];" << endl;
        }

        for (const auto& state : this->get_states()) {
            for (const auto& transition : state->transitions) {
                if (transition.second != NULL)
                    dotFile << "  " << state->id << " -> " << transition.second->id << " [label=\"" << transition.first << "\"];" << endl;
            }
        }

        dotFile << "}" << endl;
        dotFile.close();
    }



private:
    State* start_state;
    map<set<shared_ptr<NFAAlgorithm::Node>>, State*> dfa_states;//DFA状态集，用State和NFA状态集，由于set按照shared_ptr有序，因此逻辑上map.find能够正确找到元素相同的set

    /* 调试用，展示dfa状态
    */

    std::string dfa_state_to_string(const std::set<std::shared_ptr<NFAAlgorithm::Node>>& node_set) {
        std::string result = "{";
        bool first = true;

        for (const auto& node : node_set) {
            if (!first) {
                result += ", ";
            }
            result += std::to_string(node->id);  // 将节点的id转换为字符串
            first = false;
        }

        result += "}";
        return result;
    }


    vector<State*> get_states() const {
        vector<State*> states;
        for (const auto& kv : dfa_states) {
            states.push_back(kv.second);
        }
        return states;
    }

    /*
    * 计算epsilon闭包
    */
    set<shared_ptr<NFAAlgorithm::Node>> e_closure(const set<shared_ptr<NFAAlgorithm::Node>>& input) {
        stack<shared_ptr<NFAAlgorithm::Node>> unprocessed;
        set<shared_ptr<NFAAlgorithm::Node>> result(input.begin(), input.end());
        for (const shared_ptr<NFAAlgorithm::Node>& node : input) {
            unprocessed.push(node);
        }

        while (!unprocessed.empty()) {
            shared_ptr<NFAAlgorithm::Node> current = unprocessed.top();
            unprocessed.pop();
            for (const auto& edge : current->out_edges) {
                if (edge->symbol == NFAAlgorithm::EPSILON && result.insert(edge->to).second) {
                    unprocessed.push(edge->to);
                }
            }
        }

        return result;
    }
    /*
    * 获得转移状态
    */

    set<shared_ptr<NFAAlgorithm::Node>> get_transitions(shared_ptr<NFAAlgorithm::Node> node, char symbol) {
        set<shared_ptr<NFAAlgorithm::Node>> result;
        for (const auto& edge : node->out_edges) {
            if (edge->symbol == symbol) {
                result.insert(edge->to);
            }
        }
        return result;
    }

    bool contains_end_state(const set<shared_ptr<NFAAlgorithm::Node>>& states) {
        for (const shared_ptr<NFAAlgorithm::Node>& state : states) {
            if (state->is_end) {
                return true;
            }
        }
        return false;
    }
};

int main() {
    std::cout << "please cin symbols(alphabet) and regex(it can contain | . [] () and *)" << endl;
    string symbols; //e.g.: abcde
    string regex; //e.g.: (a|b)*(c|de) a|b*c|(cd)*e a[a-d]b(a|c)*
    std::cin >> symbols >> regex;
    auto solver = std::make_unique<NFAAlgorithm>(symbols, regex);
    solver->output_nfa_to_dot("nfa.dot");
    std::cout << "finished nfa.." << endl;

    vector<char> symbol_set(symbols.begin(), symbols.end());
    DFA dfa(symbol_set, solver->nfa);
    dfa.output_dfa_to_dot("dfa.dot");
    std::cout << "finished dfa.." << endl;
    // Minimize DFA (half completed)
    // dfa.output_dfa_to_dot("dfa_minimize.dot");


    return 0;
}