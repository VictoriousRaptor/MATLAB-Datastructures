classdef CStack < handle
% CStack define a stack data strcuture
% 
% It likes java.util.Stack, however, it could use CStack.content() to
% return all the data (in cells) of the Stack, and it is a litter faster
% than java's Stack.
% 
%   s = CStack(c);  c is a cells, and could be omitted
%   CStack.size() return the numble of element
%   CStack.isempty() return true when the stack is empty
%   CStack.empty() delete the content of the stack
%   CStack.push(el) push el to the top of stack
%   CStack.pop() pop out the top of the stack, and return the element
%   el = CStack.top() return the top element of the stack
%   CStack.remove() remove all the elements in the stack
%   CStack.content() return all the data of the stack (in the form of a
%   cells with size [s.size(), 1]
%   
% See also CList, CQueue
% 
% ������һ��ջ
% s = CStack; ����һ���յ�ջ����
% s = CStack(c); ����ջ���󣬲���c��ʼ��s����cΪcellʱ��c��Ԫ��Ϊ���е����ݣ�
%    ����c����Ϊ���еĵ�һ������
%
% ֧�ֲ�����
%     sz = s.size() ����ջ��Ԫ�ظ�����Ҳ�������ж�ջ�Ƿ�ǿա�
%     s.isempty() �ж�ջ�Ƿ�Ϊ��
%     s.empty() ���ջ
%     s.push(el) ����Ԫ��elѹ��ջ��
%     s.pop()  ����ջ��Ԫ�أ��û����Լ�ȷ��ջ�ǿ�
%     el = s.top() ����ջ��Ԫ�أ��û����Լ�ȷ��ջ�ǿ�
%     s.remove() ���ջ
%     s.content() ��˳�򷵻�s�����ݣ�Ϊһ��cell����
%
% See also CList, CQueue
%
% Copyright: zhang@zhiqiang.org, 2010.
% url: http://zhiqiang.org/blog/it/matlab-data-structures.html

    properties (Access = private)
        buffer      % һ��cell���飬����ջ������
        cur         % ��ǰԪ��λ��, or the length of the stack
        cap    % ջ������������������ʱ����������Ϊ2����
    end
    
    methods
        function self = CStack(c)
            starting_capacity = 100;
            if nargin >= 1 && iscell(c)
                self.buffer = c(:);
                self.cur = numel(c);
                self.cap = self.cur;
            elseif nargin >= 1
                self.buffer = cell(starting_capacity, 1);
                self.cur = 1;
                self.cap = starting_capacity;
                self.buffer{1} = c;
            else
                self.buffer = cell(starting_capacity, 1);
                self.cap = starting_capacity;
                self.cur = 0;
            end
        end
        
        function s = size(self)
            s = self.cur;
        end

        function c = capacity(self)
            c = self.cap;
        end
        
        function clear(self)
            self.cur = 0;
        end
        
        function b = empty(self)            
            b = self.cur == 0;
        end

        function push(self, el)
            if self.cur >= self.cap
                self.buffer(self.cap+1:2*self.cap) = cell(self.cap, 1);
                self.cap = 2*self.cap;
            end
            self.cur = self.cur + 1;
            self.buffer{self.cur} = el;
        end
        
        function el = top(self)
            if self.cur == 0
                el = [];
                warning('CStack:No_Data', 'trying to get top element of an emtpy stack');
            else
                el = self.buffer{self.cur};
            end
        end
        
        function el = pop(self)
            if self.cur == 0
                el = [];
                warning('CStack:No_Data', 'trying to pop element of an emtpy stack');
            else
                el = self.buffer{self.cur};
                self.cur = self.cur - 1;
            end        
        end
        
        function display(self)
            if self.cur
                for i = 1:self.cur
                    disp([num2str(i) '-th element of the stack:']);
                    disp(self.buffer{i});
                end
            else
                disp('The stack is empty');
            end
        end
        
        function c = content(self)
            c = self.buffer(1:self.cur);
        end
    end
end