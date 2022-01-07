classdef CList < handle
% ������һ��������ģ��б�
% list = CList; ����һ���յĶ��ж���
% list = CList(c); ������ж��󣬲���c��ʼ��q����cΪcellʱ��c��Ԫ��Ϊջ�����ݣ�
%    ����c����Ϊջ�ĵ�һ������
%
% ֧�ֲ�����
%     sz = CList.size() ���ض�����Ԫ�ظ���
%     y = CList.empty() ���ض����Ƿ�Ϊ��
%     CList.pushtofront(el) ����Ԫ��elѹ���б�ͷ
%     CList.pushtorear(el) ����Ԫ��elѹ���б�β��
%     el = CList.popfront()  �����б�ͷ��Ԫ�أ��û����Լ�ȷ�����зǿ�
%     el = CList.poprear() �����б�β��Ԫ�أ��û����Լ�ȷ���б�ǿ�
%     el = CList.front() ���ض���Ԫ�أ��û����Լ�ȷ�����зǿ�
%     el = CList.back() ���ض�βԪ�أ��û����Լ�ȷ�����зǿ�
%     CList.remove(k) ɾ����k��Ԫ�أ����kΪ���ģ����β����ʼ��  
%     CList.removeall() ɾ����������Ԫ��
%     CList.add(el, k) ����Ԫ��el����k��λ�ã����kΪ���ģ���ӽ�β��ʼ��
%     CList.contains(el) ���el�Ƿ�������б��У�������֣����ص�һ���±�
%     CList.get(k) �����б��ƶ�λ�õ�Ԫ�أ����kΪ���ģ����ĩβ��ʼ��
%     CList.sublist(from, to) �����б��д�from��to�����ұգ�֮�����ͼ
%     CList.content() �����б�����ݣ���һάcells�������ʽ���ء�
%     CList.toarray() = CList.content() content�ı���
%
% See also CStack
%
% copyright: zhangzq@citics.com, 2010.
% url: http://zhiqiang.org/blog/tag/matlab

    properties (Access = private)
        buffer      % һ��cell���飬����ջ������
        beg         % ������ʼλ��
        len         % ���еĳ���
        cap    % ջ������������������ʱ����������Ϊ2����
    end

    methods (Access = public)
        function self = CList(c)
            starting_capacity = 100;
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
        
        function s = size(self)
            s = self.len;
        end

        function c = capacity(self)
            c = self.cap;
        end
        
        function b = empty(self)
            b = (self.len == 0);
        end
        
        function push_back(self, el) % ѹ����Ԫ�ص���β
            self.addcapacity();
            if self.beg + self.len  <= self.cap
                self.buffer{self.beg+self.len} = el;
            else
                self.buffer{self.beg+self.len-self.cap} = el;
            end
            self.len = self.len + 1;
        end
        
        function push_front(self, el) % ѹ����Ԫ�ص���ͷ
            self.addcapacity();
            self.beg = self.beg - 1;
            if self.beg == 0
                self.beg = self.cap; 
            end
            self.buffer{self.beg} = el;
            self.len = self.len + 1;
        end
        
        function el = pop_front(self) % ��������Ԫ��
            el = self.buffer(self.beg);
            self.beg = self.beg + 1;
            self.len = self.len - 1;
            if self.beg > self.cap
                self.beg = 1;
            end
        end
        
        function el = pop_back(self) % ������βԪ��
            tmp = self.beg + self.len;
            if tmp > self.cap
                tmp = tmp - self.cap;
            end
            el = self.buffer(tmp);
            self.len = self.len - 1;
        end
        
        function el = front(self) % ���ض���Ԫ��
            try
                el = self.buffer{self.beg};
            catch ME
                throw(ME.messenge);
            end
        end
        
        function el = back(self) % ���ض�βԪ��
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
        
        function clear(self) % ����б�
            self.len = 0;
            self.beg = 1;
        end
        
        % ɾ����k��Ԫ�أ�k����Ϊ���ģ���ʾ��β����ʼ��
        function erase(self, k)
            if nargin == 2
                id = self.getindex(k);

                self.buffer{id} = [];
                self.len = self.len - 1;
                self.cap = self.cap - 1;

                % ɾ��Ԫ�غ���Ҫ���µ���beg��λ��ֵ
                if id < self.beg
                    self.beg = self.beg - 1;
                end
            end
        end
        
        % ������Ԫ��el����k��Ԫ��֮ǰ�����kΪ����������뵽������-k��Ԫ��֮��
        function insert(self, el, k)
            self.addcapacity();
            id = self.getindex(k);
            
            if k > 0 % �����ڵ�id��Ԫ��֮ǰ
                self.buffer = [self.buffer(1:id-1); el; self.buffer(id:end)];
                if id < self.beg
                    self.beg = self.beg + 1;
                end
            else % k < 0�������ڵ�id��Ԫ��֮��
                self.buffer = [self.buffer(1:id); el; self.buffer(id:end)];
                if id < self.beg
                    self.beg = self.beg + 1;
                end
            end
        end
        
        % ������ʾ����Ԫ��
        function display(self)
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
        
        
        % ��ȡ�б����������
        function c = content(self)
            rear = self.beg + self.len - 1;
            if rear <= self.cap
                c = self.buffer(self.beg:rear);                    
            else
                c = self.buffer([self.beg:self.cap 1:rear]);
            end
        end
        
        % ��ȡ�б���������ݣ���ͬ��self.content();
        function c = toarray(self)
            c = self.content();
        end
    end
    
    methods (Access = private)
        
        % getindex(k) ���ص�k��Ԫ����buffer���±�λ��
        function id = getindex(self, k)
            if k > 0
                id = self.beg + k;
            else
                id = self.beg + self.len + k;
            end     
            
            if id > self.cap
                id = id - self.cap;
            end
        end
        
        % ��buffer��Ԫ�ظ����ӽ���������ʱ��������������һ����
        % ��ʱ��ת�б�ʹ�ô�1��ʼ�������б��������������Ͽ�λ��
        function addcapacity(self)
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
    end % private methos
    
    methods (Abstract)
        
    end
end