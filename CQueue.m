classdef CQueue < handle
% CQueue define a queue data strcuture
% 
% It likes java.util.Queue, however, it could use CQueue.content() to
% return all the data (in cells) of the Queue, and it is a litter faster
% than java's Queue.
% 
%   q = CQueue(c); c is a cells, and could be omitted
%   s.size() return the numble of element
%   s.isempty() return true when the queue is empty
%   s.empty() delete all the elements in the queue.
%   s.push(el) push el to the top of qeueu
%   s.pop() pop out the the beginning of queue, and return the element
%   s.front() return the the the beginning element of the qeueu
%   s.back() return the the the rear element of the qeueu
%   s.remove() remove all data from the queue
%   s.content() return all the data of the queue (in the form of a
%   cells with size [s.size(), 1]
%   
% See also CList, CStack
%
% 定义了一个队列
% q = CQueue; 定义一个空的队列对象
% q = CQueue(c); 定义队列对象，并用c初始化q，当c为cell时，c的元素为栈的数据，
%    否则c本身为栈的第一个数据
%
% 支持操作：
%     sz = q.size() 返回队列内元素个数，也可用来判断队列是否非空。
%     q.isempty() 用来判断队列为空
%     q.empty() 清空队列
%     q.push(el) 将新元素el压入队列内
%     s.pop()  弹出队首元素，用户需自己确保队列非空
%     el = q.front() 返回队首元素，用户需自己确保队列非空
%     el = q.back() 返回队尾元素，用户需自己确保队列非空
%     q.remove() 清空队列
%     q.content() 按顺序返回q的数据，为一个cell数组
%     
% See also CStack, CList
%
% Copyright: zhang@zhiqiang.org, 2010.
% url: http://zhiqiang.org/blog/it/matlab-data-structures.html

    properties (Access = private)
        buffer      % a cell, to maintain the data
        beg         % the start position of the queue
        rear        % the end position of the queue
                    % the actually data is buffer(beg:rear-1)
        cap    % 栈的容量，当容量不够时，容量扩充为2倍。
    end
    
    properties (Access = public)
        
    end
    
    methods
        function self = CQueue(c) % 初始化
            starting_capacity = 100;
            if nargin >= 1 && iscell(c)
                self.buffer = [c(:); cell(numel(c), 1)];
                self.beg = 1;
                self.rear = numel(c) + 1;
                self.cap = 2*numel(c);
            elseif nargin >= 1
                self.buffer = cell(starting_capacity, 1);
                self.buffer{1} = c;
                self.beg = 1;
                self.rear = 2;
                self.cap = starting_capacity;                
            else
                self.buffer = cell(starting_capacity, 1);
                self.cap = starting_capacity;
                self.beg = 1;
                self.rear = 1;
            end
        end
        
        function s = size(self)  % Can be used as size(queue)
            if self.rear >= self.beg
                s = self.rear - self.beg;
            else
                s = self.rear - self.beg + self.cap;
            end
        end

        function n = numel(self)  % Can be used as numel(numel)
            n = self.size();
        end
        
        function c = capacity(self)
            c = self.cap;
        end

        function b = empty(self)   % return true when the queue is empty
            b = self.size() == 0;
        end
        
        function s = clear(self) % clear all the data in the queue
            s = self.size();
            self.beg = 1;
            self.rear = 1;
        end
        
        function push(self, el) % 压入新元素到队尾
            if self.size >= self.cap - 1
                sz = self.size();
                if self.rear >= self.front
                    self.buffer(1:sz) = self.buffer(self.beg:self.rear-1);                    
                else
                    self.buffer(1:sz) = self.buffer([self.beg:self.cap 1:self.rear-1]);
                end
                self.buffer(sz+1:self.cap*2) = cell(self.cap*2-sz, 1);
                self.cap = numel(self.buffer);
                self.beg = 1;
                self.rear = sz+1;
            end
            self.buffer{self.rear} = el;
            self.rear = mod(self.rear, self.cap) + 1;
        end
        
        function el = front(self) % 返回队首元素
            if self.rear ~= self.beg
                el = self.buffer{self.beg};
            else
                el = [];
                warning('CQueue:NO_DATA', 'try to get data from an empty queue');
            end
        end
        
        function el = back(self) % 返回队尾元素            
            
           if self.rear == self.beg
               el = [];
               warning('CQueue:NO_DATA', 'try to get data from an empty queue');
           else
               if self.rear == 1
                   el = self.buffer{self.cap};
               else
                   el = self.buffer{self.rear - 1};
               end
            end
            
        end
        
        function el = pop(self) % 弹出队首元素
            if self.rear == self.beg
                error('CQueue:NO_Data', 'Trying to pop an empty queue');
            else
                el = self.buffer{self.beg};
                self.beg = self.beg + 1;
                if self.beg > self.cap, self.beg = 1; end
            end             
        end
        
        function remove(self) % 清空队列
            self.beg = 1;
            self.rear = 1;
        end
        
        function disp(self) % 显示队列
            if self.size()
                if self.beg <= self.rear 
                    for i = self.beg : self.rear-1
                        disp([num2str(i - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end
                else
                    for i = self.beg : self.cap
                        disp([num2str(i - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end     
                    for i = 1 : self.rear-1
                        disp([num2str(i + self.cap - self.beg + 1) '-th element of the stack:']);
                        disp(self.buffer{i});
                    end
                end
            else
                disp('The queue is empty');
            end
        end
        
        function c = content(self) % 取出队列元素
            if self.rear >= self.beg
                c = self.buffer(self.beg:self.rear-1);                    
            else
                c = self.buffer([self.beg:self.cap 1:self.rear-1]);
            end
        end
    end
end