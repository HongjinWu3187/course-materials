//题中代码实现的功能为：遍历数组A，将每个数组元素的2倍存入数组B，并返回数组B的和
//本代码能实现：先输入数组A的元素个数，再依次输入A的各个元素，进而实现题中代码的功能（本代码最后将AB内存释放）

#include <iostream>
using namespace std;

int main()
{
	cout<<"请输入数组A的元素个数：";
	int n,sum=0,i=0;
	cin>>n;
	int *A=new int[n];int *B=new int[n];
	cout<<"请依次输入数组A的各个元素："<<endl;
	for(i=0;i<n;i++) cin>>A[i];
	for(i=0;i<n;i++){
		B[i]=A[i]*2;
		sum+=B[i];
	}
	cout<<"数组B：";
	for(i=0;i<n;i++) cout<<B[i]<<" ";
	cout<<endl<<"所求和为："<<sum<<endl;
	delete []B;
	delete []A;
	return 0;
}