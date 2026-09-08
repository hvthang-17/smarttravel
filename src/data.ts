export type Place = {
  id: string
  name: string
  area: string
  description: string
  category: string
  duration: string
  rating: number
  price: string
  image: string
  accent: string
}

export const places: Place[] = [
  {
    id: 'son-tra',
    name: 'Bán đảo Sơn Trà',
    area: 'Sơn Trà, Đà Nẵng',
    description: 'Cung đường ven biển xanh mát, lý tưởng để ngắm bình minh.',
    category: 'Thiên nhiên',
    duration: '3 giờ',
    rating: 4.9,
    price: 'Miễn phí',
    image: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=900&q=80',
    accent: '#d9f1e9',
  },
  {
    id: 'ngu-hanh-son',
    name: 'Ngũ Hành Sơn',
    area: 'Ngũ Hành Sơn, Đà Nẵng',
    description: 'Khám phá hang động, chùa cổ và những góc nhìn tuyệt đẹp.',
    category: 'Văn hóa',
    duration: '2 giờ',
    rating: 4.7,
    price: '40.000đ',
    image: 'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=900&q=80',
    accent: '#fbe8cd',
  },
  {
    id: 'my-khe',
    name: 'Bãi biển Mỹ Khê',
    area: 'Sơn Trà, Đà Nẵng',
    description: 'Bãi biển cát trắng nổi tiếng, thư giãn và đón hoàng hôn.',
    category: 'Biển',
    duration: '2 giờ',
    rating: 4.8,
    price: 'Miễn phí',
    image: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=900&q=80',
    accent: '#dcecf7',
  },
  {
    id: 'ba-na',
    name: 'Bà Nà Hills',
    area: 'Hòa Vang, Đà Nẵng',
    description: 'Một ngày vui chơi giữa mây trời với Cầu Vàng biểu tượng.',
    category: 'Giải trí',
    duration: 'Cả ngày',
    rating: 4.6,
    price: '900.000đ',
    image: 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?auto=format&fit=crop&w=900&q=80',
    accent: '#eee6fa',
  },
]
