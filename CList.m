classdef CList < handle
% A List
% list = CList(); Construct an empty list object
% list = CList(c); Construct a list: if c is a cell, then the list is
%     initialized with c's elements; otherwise c becomes the first element
%
% Methods：
%     sz = CList.size() Return size
%     y = CList.empty() Test whether container is empty
%     c = CList.capacity() Return current capacity(buffer size)
%     CList.clear() Clear content
%     CList.push_front(el) Insert element at beginning
%     CList.push_back(el) Add element at the end
%     el = CList.pop_front() Delete first element
%     el = CList.pop_back() Delete last element
%     el = CList.front() Return first element
%     el = CList.back() Return last element
%     CList.erase(k) Erase the k-th element, if k is negative, then erase 
%     the reverse k-th element
%     CList.insert(el, k) Insert a new element at the k-th position, k can
%     be negative
%     CList.content() Return a 1-D cell array containing all data
%     numel(instance) Return size
%     size(instance) Return size
%
% copyright: zhangzq@citics.com, 2010.
% url: http://zhiqiang.org/blog/tag/matlab
%
% Modified by VictoriousRaptor
% See https://github.com/VictoriousRaptor/MATLAB-Datastructures

    properties (Access = private)
        buffer      % A cell array
        beg         % beginning pos of the list
        last        % last pos, empty, next available pos
        len         % length
        cap         % capacity
    end

    methods (Access = public)
        % if c is cell array then use its elements, otherwise c will be the first element
        function self = CList(c)
            starting_capacity = 5;
            if nargin >= 1 && iscell(c)
                self.buffer = [c(:), cell(1, numel(c))];
                self.beg = 1;
                self.len = numel(c);
                self.cap = self.len;
                self.last = self.len + 1;
            elseif nargin >= 1
                self.buffer = cell(1, starting_capacity);
                self.buffer{1} = c;
                self.beg = 1;
                self.last = 1;
                self.len = 1;
                self.cap = starting_capacity;                
            else
                self.buffer = cell(1, starting_capacity);
                self.cap = starting_capacity;
                self.beg = 1;
                self.last = 1;
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

        function clear(self)
            self.len = 0;
            self.beg = 1;
            self.last = 2;
        end
        
        function push_back(self, el)  % push a new element to the back
            self.increase_capacity();
            self.buffer{self.last} = el;
            self.len = self.len + 1;
            self.last = mod(self.beg + self.len, self.cap);
        end
        
        function push_front(self, el)  % push a new element to the front
            self.increase_capacity();
            self.beg = self.beg - 1;
            if self.beg == 0
                self.beg = self.cap; 
            end
            self.buffer{self.beg} = el;
            self.len = self.len + 1;
            self.last = mod(self.beg + self.len, self.cap);
        end
        
        function el = pop_front(self)  % pop the first element
            el = self.buffer(self.beg);
            self.len = self.len - 1;
            self.beg = self.beg + 1;
            if self.beg > self.cap
                self.beg = 1;
            end
        end
        
        function el = pop_back(self)  % pop the last element
            tmp = self.beg + self.len;
            if tmp > self.cap
                tmp = tmp - self.cap;
            end
            el = self.buffer(tmp);
            self.len = self.len - 1;
            self.last = mod(self.beg + self.len, self.cap);
        end
        
        function el = front(self)  % get the first element
            try
                el = self.buffer{1, self.beg};
            catch ME
                throw(ME.messenge);
            end
        end
        
        function el = back(self)  % get the last element
            try
                el = self.buffer{1, self.get_index(self.len)};
            catch ME
                throw(ME.messenge);
            end            
        end
        
        % Erase the k-th element, if k is negative, then erase the reverse k-th
        % element
        % TODO erase range
        function erase(self, k)
            if self.empty()
                error('CList: erasing element in a empty list')
            elseif k == 0
                error('CList: erasing the 0-th elementt')
            end
            id = self.get_index(k);
            if self.last < self.beg && id <= self.last - 2
%                for i = id:self.last - 2
%                    self.buffer{i} = self.buffer{i + 1};
%                end
               self.buffer{id:self.last - 2} = self.buffer{id + 1: self.last - 1};
            elseif self.beg + 1 < id
%                 for i = self.beg + 1:id
%                     self.buffer{i} = self.buffer{i - 1};
%                 end
                self.buffer{self.beg:id} = self.buffer{self.beg - 1:id - 1};
                self.beg = self.beg + 1;
            end
            self.len = self.len - 1;
            self.last = mod(self.beg + self.len, self.cap);
        end
        
        % Insert a new element at the element at the specified position k
        % k can be negative (reverse index), in this case, the new element will be
        % inserted AFTER the original one
        function insert(self, el, k)
            if k == 0
                error('CList: accessing the 0-th elementt')
            end
            self.increase_capacity();
            if k == self.len + 1
                self.push_back(el);
                return
            elseif k == -(self.len + 1)
                self.push_front(el);
                return
            end
            id = self.get_index(k);
            if k > 0
                if self.last > id
                    for i = self.last:-1:id + 1
                        self.buffer{i} = self.buffer{i - 1};
                    end
                    self.buffer{id} = el;
                else
                    for i = self.beg - 1:self.id - 1
                        self.buffer{i} = self.buff{i + 1};
                    end
                    self.buffer{id} = el;
                end 
            else
                k = self.len + k + 1;
                self.insert(el, k + 1);
            end
            self.len = self.len + 1;
            self.last = mod(self.beg + self.len, self.cap);
        end

        % Replace  the element at the specified position k
        % k can be negative (reverse index)
        function replace(self, el, k)
            if k == 0
                error('CList: accessing the 0-th elementt')
            end
            self.increase_capacity();
            id = self.get_index(k);
            self.buffer{id} = el;
        end
        
        % Display elements
        function disp(self)
            if ~self.empty()
                if self.last > self.beg
                    for i = self.beg:self.last - 1
                        disp([num2str(i - self.beg + 1) '-th element of the list:']);
                        disp(self.buffer{i});
                    end
                else
                    for i = self.beg : self.cap
                        disp([num2str(i - self.beg + 1) '-th element of the list:']);
                        disp(self.buffer{i});
                    end     
                    for i = 1 :self.last - 1  % loop
                        disp([num2str(i + self.cap - self.beg + 1) '-th element of the list:']);
                        disp(self.buffer{i});
                    end
                end
            else
                disp('This list is empty');
            end
        end
        
        
        % Return all content
        function c = content(self)
            if self.empty()
                c = {};
            end
            if self.last > self.beg
                c = self.buffer(self.beg:self.last - 1);                    
            else
                c = self.buffer([self.beg:self.cap, 1:self.last - 1]);
            end
        end
        
    end
    
    methods (Access = private)
        
        % get the buffer index of the k-th element
        function id = get_index(self, k)
            if k > 0
                id = self.beg + k - 1;
            else
                id = self.beg + self.len + k;
            end     
            
            if id > self.cap
                id = id - self.cap;
            end
        end

        function increase_capacity(self)
            if self.len == self.cap - 1
                self.buffer = [self.buffer, cell(1, self.cap)];
                if self.beg > 2  %  must be a loop
                    self.buffer(self.cap + 1, self.cap + self.beg - 1) = self.buffer(1:self.beg - 2);
                end
                self.cap = self.cap * 2;
                self.last = mod(self.beg + self.len, self.cap);
            end
        end
        
    end

end