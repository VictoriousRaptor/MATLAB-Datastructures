classdef CList < handle
% 定义了一个（有序的）列表
% list = CList; 定义一个空的队列对象
% list = CList(c); 定义队列对象，并用c初始化q，当c为cell时，c的元素为栈的数据，
%    否则c本身为栈的第一个数据
%
% 支持操作：
%     sz = CList.size() 返回队列内元素个数
%     y = CList.empty() 返回队列是否为空
%     CList.pushtofront(el) 将新元素el压入列表头
%     CList.pushtorear(el) 将新元素el压入列表尾部
%     el = CList.popfront()  弹出列表头部元素，用户需自己确保队列非空
%     el = CList.poprear() 弹出列表尾部元素，用户需自己确保列表非空
%     el = CList.front() 返回队首元素，用户需自己确保队列非空
%     el = CList.back() 返回队尾元素，用户需自己确保队列非空
%     CList.remove(k) 删除第k个元素，如果k为负的，则从尾部开始算  
%     CList.removeall() 删除队列所有元素
%     CList.add(el, k) 插入元素el到第k个位置，如果k为负的，则从结尾开始算
%     CList.contains(el) 检查el是否出现在列表中，如果出现，返回第一个下标
%     CList.get(k) 返回列表制定位置的元素，如果k为负的，则从末尾开始算
%     CList.sublist(from, to) 返回列表中从from到to（左开右闭）之间的视图
%     CList.content() 返回列表的数据，以一维cells数组的形式返回。
%     CList.toarray() = CList.content() content的别名
%
% See also CStack
%
% copyright: zhangzq@citics.com, 2010.
% url: http://zhiqiang.org/blog/tag/matlab

    properties (Access = private)
        buffer      % 一个cell数组，保存栈的数据
        beg         % 队列起始位置
        len         % 队列的长度
        cap    % 栈的容量，当容量不够时，容量扩充为2倍。
    end

    methods (Access = public)
        function self = CList(c)
            starting_capacity = 5;
            if nargin >= 1 && iscell(c)
                self.buffer = [c(:); cell(numel(c), 1)];
                self.beg = 1;
                self.len = numel(c);
                self.cap = 2*numel(c);
            elseif nargin >= 1
                self.buffer = cell(starting_capacity, 1);
                self.buffer{1} = c;
                self.beg = 1;
                self.len = 1;
                self.cap = starting_capacity;                
            else
                self.buffer = cell(starting_capacity, 1);
                self.cap = starting_capacity;
                self.beg = 1;
                self.len = 0;
            end
        end
        
        function s = size(self)   % Can be used as size(list)
            s = self.len;
        end

        function n = numel(self)  % Can be used as numel(list)
            n = self.len;
        end

        function c = capacity(self)
            c = self.cap;
        end
        
        function b = empty(self)
            b = (self.len == 0);
        end

        function clear(self) % 清空列表
            self.len = 0;
            self.beg = 1;
        end
        
        function push_back(self, el) % 压入新元素到队尾
            self.increase_capacity();
            if self.beg + self.len  <= self.cap
                self.buffer{self.beg+self.len} = el;
            else
                self.buffer{self.beg+self.len-self.cap} = el;
            end
            self.len = self.len + 1;
        end
        
        function push_front(self, el) % 压入新元素到队头
            self.increase_capacity();
            self.beg = self.beg - 1;
            if self.beg == 0
                self.beg = self.cap; 
            end
            self.buffer{self.beg} = el;
            self.len = self.len + 1;
        end
        
        function el = pop_front(self) % 弹出队首元素
            el = self.buffer(self.beg);
            self.beg = self.beg + 1;
            self.len = self.len - 1;
            if self.beg > self.cap
                self.beg = 1;
            end
        end
        
        function el = pop_back(self) % 弹出队尾元素
            tmp = self.beg + self.len;
            if tmp > self.cap
                tmp = tmp - self.cap;
            end
            el = self.buffer(tmp);
            self.len = self.len - 1;
        end
        
        function el = front(self) % 返回队首元素
            try
                el = self.buffer{self.beg};
            catch ME
                throw(ME.messenge);
            end
        end
        
        function el = back(self) % 返回队尾元素
            try
                tmp = self.beg + self.len - 1;
                if tmp >= self.cap
                    tmp = tmp - self.cap;
                end
                el = self.buffer(tmp);
            catch ME
                throw(ME.messenge);
            end            
        end
        
        % 删除第k个元素，k可以为负的，表示从尾部开始算
        function erase(self, k)
            if nargin == 2
                id = self.get_index(k);

                self.buffer{id} = [];
                self.len = self.len - 1;
                self.cap = self.cap - 1;

                % 删除元素后，需要重新调整beg的位置值
                if id < self.beg
                    self.beg = self.beg - 1;
                end
            end
        end
        
        % 插入新元素el到第k个元素之前，k可以为负数
        function insert(self, el, k)
            self.increase_capacity();
            id = self.get_index(k);
            
            if k > 0 % 插入在第id个元素之前
                self.buffer = [self.buffer(1:id-1); el; self.buffer(id:end)];
                if id < self.beg
                    self.beg = self.beg + 1;
                end
            end
        end
        
        % 依次显示队列元素
        function disp(self)
            if self.size()
                rear = self.beg + self.len - 1;
                if rear <= self.cap
                    for i = self.beg : rear
                        disp([num2str(i - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end
                else
                    for i = self.beg : self.cap
                        disp([num2str(i - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end     
                    for i = 1 : rear
                        disp([num2str(i + self.cap - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end
                end
            else
                disp('The queue is empty');
            end
        end
        
        
        % 获取列表的数据内容
        function c = content(self)
            rear = self.beg + self.len - 1;
            if rear <= self.cap
                c = self.buffer(self.beg:rear);                    
            else
                c = self.buffer([self.beg:self.cap 1:rear]);
            end
        end
        
    end
    
    methods (Access = private)
        
        % getindex(k) 返回第k个元素在buffer的下标位置
        function id = get_index(self, k)
            if k > 0
                id = self.beg + k;
            else
                id = self.beg + self.len + k;
            end     
            
            if id > self.cap
                id = id - self.cap;
            end
        end
        
        % 当buffer的元素个数接近容量上限时，将其容量扩充一倍。
        % 此时旋转列表，使得从1开始。整个列表至少有两个以上空位。
        function increase_capacity(self)
            if self.len >= self.cap - 1
                sz = self.len;
                if self.beg + sz - 1 <= self.cap
                    self.buffer(1:sz) = self.buffer(self.beg:self.beg+sz-1);                    
                else
                    self.buffer(1:sz) = self.buffer([self.beg:self.cap, ...
                        1:sz-(self.cap-self.beg+1)]);
                end
                self.buffer(sz+1:self.cap*2) = cell(self.cap*2-sz, 1);
                self.cap = 2*self.cap;
                self.beg = 1;
            end
        end
    end % private methods

end