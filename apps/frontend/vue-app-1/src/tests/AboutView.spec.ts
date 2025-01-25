import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import AboutView from '../views/AboutView.vue';

describe('AboutView.vue', () => {
  it('renders the heading text', () => {
    const wrapper = mount(AboutView);
    const heading = wrapper.find('h1');
    expect(heading.exists()).toBe(true);
    expect(heading.text()).toBe('This is an about page');
  });

  it('has the .about class on the wrapper div', () => {
    const wrapper = mount(AboutView);
    const aboutDiv = wrapper.find('.about');
    expect(aboutDiv.exists()).toBe(true);
  });
});
