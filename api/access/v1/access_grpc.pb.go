// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.5.1
// - protoc             (unknown)
// source: access/v1/access.proto

package access

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.64.0 or later.
const _ = grpc.SupportPackageIsVersion9

const (
	Access_Evaluation_FullMethodName  = "/authzen.access.v1.Access/Evaluation"
	Access_Evaluations_FullMethodName = "/authzen.access.v1.Access/Evaluations"
)

// AccessClient is the client API for Access service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type AccessClient interface {
	// evaluation
	Evaluation(ctx context.Context, in *EvaluationRequest, opts ...grpc.CallOption) (*EvaluationResponse, error)
	// evaluations
	Evaluations(ctx context.Context, in *EvaluationsRequest, opts ...grpc.CallOption) (*EvaluationsResponse, error)
}

type accessClient struct {
	cc grpc.ClientConnInterface
}

func NewAccessClient(cc grpc.ClientConnInterface) AccessClient {
	return &accessClient{cc}
}

func (c *accessClient) Evaluation(ctx context.Context, in *EvaluationRequest, opts ...grpc.CallOption) (*EvaluationResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(EvaluationResponse)
	err := c.cc.Invoke(ctx, Access_Evaluation_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *accessClient) Evaluations(ctx context.Context, in *EvaluationsRequest, opts ...grpc.CallOption) (*EvaluationsResponse, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(EvaluationsResponse)
	err := c.cc.Invoke(ctx, Access_Evaluations_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// AccessServer is the server API for Access service.
// All implementations should embed UnimplementedAccessServer
// for forward compatibility.
type AccessServer interface {
	// evaluation
	Evaluation(context.Context, *EvaluationRequest) (*EvaluationResponse, error)
	// evaluations
	Evaluations(context.Context, *EvaluationsRequest) (*EvaluationsResponse, error)
}

// UnimplementedAccessServer should be embedded to have
// forward compatible implementations.
//
// NOTE: this should be embedded by value instead of pointer to avoid a nil
// pointer dereference when methods are called.
type UnimplementedAccessServer struct{}

func (UnimplementedAccessServer) Evaluation(context.Context, *EvaluationRequest) (*EvaluationResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Evaluation not implemented")
}
func (UnimplementedAccessServer) Evaluations(context.Context, *EvaluationsRequest) (*EvaluationsResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Evaluations not implemented")
}
func (UnimplementedAccessServer) testEmbeddedByValue() {}

// UnsafeAccessServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to AccessServer will
// result in compilation errors.
type UnsafeAccessServer interface {
	mustEmbedUnimplementedAccessServer()
}

func RegisterAccessServer(s grpc.ServiceRegistrar, srv AccessServer) {
	// If the following call pancis, it indicates UnimplementedAccessServer was
	// embedded by pointer and is nil.  This will cause panics if an
	// unimplemented method is ever invoked, so we test this at initialization
	// time to prevent it from happening at runtime later due to I/O.
	if t, ok := srv.(interface{ testEmbeddedByValue() }); ok {
		t.testEmbeddedByValue()
	}
	s.RegisterService(&Access_ServiceDesc, srv)
}

func _Access_Evaluation_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(EvaluationRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(AccessServer).Evaluation(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Access_Evaluation_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(AccessServer).Evaluation(ctx, req.(*EvaluationRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Access_Evaluations_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(EvaluationsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(AccessServer).Evaluations(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Access_Evaluations_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(AccessServer).Evaluations(ctx, req.(*EvaluationsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// Access_ServiceDesc is the grpc.ServiceDesc for Access service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var Access_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "authzen.access.v1.Access",
	HandlerType: (*AccessServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Evaluation",
			Handler:    _Access_Evaluation_Handler,
		},
		{
			MethodName: "Evaluations",
			Handler:    _Access_Evaluations_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "access/v1/access.proto",
}
