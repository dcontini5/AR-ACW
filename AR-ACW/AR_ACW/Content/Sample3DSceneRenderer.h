#pragma once

#include "..\Common\DeviceResources.h"
#include "ShaderStructures.h"
#include "..\Common\StepTimer.h"
#include "DDSTextureLoader.h"
#include <vector>
#include <DirectXMath.h>


#define RT 1

namespace AR_ACW
{
	// This sample renderer instantiates a basic rendering pipeline.
	class Sample3DSceneRenderer
	{
	public:
		Sample3DSceneRenderer(const std::shared_ptr<DX::DeviceResources>& deviceResources);
		void CreateDeviceDependentResources();
		void CreateWindowSizeDependentResources();
		void ReleaseDeviceDependentResources();
		void Update(DX::StepTimer const& timer);
		void Render();
		void StartTracking();
		void TrackingUpdate(float positionX);
		void StopTracking();
		bool IsTracking() { return m_tracking; }


	private:
		void Rotate(float radians);

	private:
		// Cached pointer to device resources.
		std::shared_ptr<DX::DeviceResources> m_deviceResources;

		// Direct3D resources for cube geometry.
		Microsoft::WRL::ComPtr<ID3D11InputLayout>			m_inputLayout;
		Microsoft::WRL::ComPtr<ID3D11Buffer>				m_vertexBuffer;
		Microsoft::WRL::ComPtr<ID3D11Buffer>				m_indexBufferPoint;
		Microsoft::WRL::ComPtr<ID3D11Buffer>				m_indexBufferRayCasting;
		Microsoft::WRL::ComPtr<ID3D11VertexShader>			m_vertexShader;
		Microsoft::WRL::ComPtr<ID3D11VertexShader>			m_vertexShaderRM;
		//Microsoft::WRL::ComPtr<ID3D11VertexShader>		m_vertexShader;
		Microsoft::WRL::ComPtr<ID3D11PixelShader>			m_pixelShader;
		Microsoft::WRL::ComPtr<ID3D11PixelShader>			m_pixelShaderRM;
		Microsoft::WRL::ComPtr<ID3D11PixelShader>			m_pixelShaderFlag;
		Microsoft::WRL::ComPtr<ID3D11GeometryShader>		m_geometryShader;
		Microsoft::WRL::ComPtr<ID3D11GeometryShader>		m_geometryShaderFlag;
		Microsoft::WRL::ComPtr<ID3D11GeometryShader>		m_geometryShaderCloud;
		Microsoft::WRL::ComPtr<ID3D11Buffer>				m_constantBuffer;
		Microsoft::WRL::ComPtr<ID3D11RasterizerState>		m_rasterState;
		Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>	m_soldierText;
		Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>	m_cloudText;
		Microsoft::WRL::ComPtr<ID3D11Texture2D>				m_texture;
		Microsoft::WRL::ComPtr<ID3D11Texture2D>				m_DepthStencil;
		Microsoft::WRL::ComPtr<ID3D11SamplerState>			m_sampler;
		Microsoft::WRL::ComPtr<ID3D11DepthStencilState>		m_DSStateOFF;
		Microsoft::WRL::ComPtr<ID3D11DepthStencilState>		m_DSStateON;
		Microsoft::WRL::ComPtr<ID3D11RenderTargetView>		m_RTV;
		
		
		// System resources for cube geometry.
		ModelViewProjectionConstantBuffer	m_constantBufferData;
		uint32	m_indexCountRayCasting;
		uint32	m_indexCountPoint;

		// Variables used with the rendering loop.
		bool	m_loadingComplete;
		float	m_degreesPerSecond;
		bool	m_tracking;
		float	_time;
		float	_dt;
		
		std::vector<DirectX::XMFLOAT3> _pos;
	};
}

